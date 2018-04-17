#!/usr/bin/env bash

set -eu
export LC_ALL=C

CONFIGURE_CLOUD_ROUTES=false

#FIXME(yuanying): make this be configmap
if [[ ${KUBE_CLOUD_PROVIDER} == "openstack" ]]; then
  KUBE_CLOUD_CONFIG_BASENAME=$(basename ${KUBE_CLOUD_CONFIG})
  KUBE_CLOUD_CONFIG_DIRNAME=$(dirname ${KUBE_CLOUD_CONFIG})
  KUBE_CLOUD_CONFIG_MOUNT="
        - mountPath: "${KUBE_CLOUD_CONFIG}"
          name: kube-cloud-config
          subPath: "${KUBE_CLOUD_CONFIG_BASENAME}"
          readOnly: false
"
  KUBE_CLOUD_CONFIG_VOLUME="
      - name: kube-cloud-config
        hostPath:
          path: "${KUBE_CLOUD_CONFIG_DIRNAME}"
"
  CONFIGURE_CLOUD_ROUTES=true
fi

KUBE_TEMPLATE=${LOCAL_MANIFESTS_DIR}/kube-controller-manager.yaml

CA=$(cat ${KUBE_CA_CERT} | base64 | tr -d '\n')
SA_KEY=$(cat ${KUBE_SA_KEY} | base64 | tr -d '\n')

cat << EOF > $KUBE_TEMPLATE
---
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: kube-controller-manager
  namespace: kube-system
spec:
  minAvailable: 1
  selector:
    matchLabels:
      tier: control-plane
      k8s-app: kube-controller-manager
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: remora:kube-controller-manager
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-controller-manager
subjects:
- kind: ServiceAccount
  name: kube-controller-manager
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kube-controller-manager
  namespace: kube-system
---
apiVersion: v1
data:
  ca.crt: ${CA}
  service-account.key: ${SA_KEY}
kind: Secret
metadata:
  name: kube-controller-manager
  namespace: kube-system
type: Opaque
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kube-controller-manager
  namespace: kube-system
  labels:
    tier: control-plane
    k8s-app: kube-controller-manager
spec:
  replicas: 2
  selector:
    matchLabels:
      tier: control-plane
      k8s-app: kube-controller-manager
  template:
    metadata:
      labels:
        tier: control-plane
        k8s-app: kube-controller-manager
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ''
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: tier
                  operator: In
                  values:
                  - control-plane
                - key: k8s-app
                  operator: In
                  values:
                  - kube-controller-manager
              topologyKey: kubernetes.io/hostname
      containers:
      - name: kube-controller-manager
        image: ${KUBE_HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION}
        command:
        - ./hyperkube
        - controller-manager
        - --allocate-node-cidrs=true
        - --cloud-provider=
        - --cluster-cidr=${KUBE_CLUSTER_CIDR}
        - --node-cidr-mask-size=${KUBE_NODE_CIDR_MASK_SIZE}
        - --configure-cloud-routes=${CONFIGURE_CLOUD_ROUTES}
        - --leader-elect=true
        - --root-ca-file=/etc/kubernetes/secrets/ca.crt
        - --use-service-account-credentials=true
        - --service-account-private-key-file=/etc/kubernetes/secrets/service-account.key
        - --cloud-provider=${KUBE_CLOUD_PROVIDER:-""}
        - --cloud-config=${KUBE_CLOUD_CONFIG:-""}
        - --v=${KUBE_LOG_LEVEL:-"2"}
        livenessProbe:
          httpGet:
            path: /healthz
            port: 10252  # Note: Using default port. Update if --port option is set differently.
          initialDelaySeconds: 15
          timeoutSeconds: 15
        volumeMounts:
        - name: secrets
          mountPath: /etc/kubernetes/secrets
          readOnly: true
        - name: ssl-host
          mountPath: /etc/ssl/certs
          readOnly: true
${KUBE_CLOUD_CONFIG_MOUNT:-""}
      nodeSelector:
        node-role.kubernetes.io/master: ""
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
      serviceAccountName: kube-controller-manager
      tolerations:
      - key: CriticalAddonsOnly
        operator: Exists
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      volumes:
      - name: secrets
        secret:
          secretName: kube-controller-manager
      - name: ssl-host
        hostPath:
          path: /usr/share/ca-certificates
${KUBE_CLOUD_CONFIG_VOLUME:-""}
      dnsPolicy: Default # Don't use cluster DNS.

EOF
