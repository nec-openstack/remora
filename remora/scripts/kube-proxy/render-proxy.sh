#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBE_PROXY_TEMPLATE=${LOCAL_MANIFESTS_DIR}/kube-proxy.yaml
cat << EOF > $KUBE_PROXY_TEMPLATE
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: remora:node-proxier
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:node-proxier
subjects:
- kind: ServiceAccount
  name: kube-proxy
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kube-proxy
  namespace: kube-system
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: kube-proxy
  namespace: kube-system
  labels:
    app: kube-proxy
data:
  kubeconfig.conf: |
    apiVersion: v1
    kind: Config
    clusters:
    - cluster:
        certificate-authority: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        server: https://${KUBE_PUBLIC_SERVICE_IP}:${KUBE_PORT}
      name: default
    contexts:
    - context:
        cluster: default
        namespace: default
        user: default
      name: default
    current-context: default
    users:
    - name: default
      user:
        tokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  labels:
    k8s-app: kube-proxy
  name: kube-proxy
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: kube-proxy
  updateStrategy:
    type: RollingUpdate
  template:
    metadata:
      labels:
        k8s-app: kube-proxy
    spec:
      containers:
      - name: kube-proxy
        image: ${KUBE_HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION}
        imagePullPolicy: IfNotPresent
        command:
        - /hyperkube
        - proxy
        - --kubeconfig=/var/lib/kube-proxy/kubeconfig.conf
        - --cluster-cidr=${KUBE_CLUSTER_CIDR}
        - --hostname-override=\$(NODE_NAME)
        env:
          - name: NODE_NAME
            valueFrom:
              fieldRef:
                fieldPath: spec.nodeName
        securityContext:
          privileged: true
        volumeMounts:
        - mountPath: /var/lib/kube-proxy
          name: kube-proxy
        # TODO: Make this a file hostpath mount
        - mountPath: /run/xtables.lock
          name: xtables-lock
          readOnly: false
      hostNetwork: true
      serviceAccountName: kube-proxy
      # TODO: Why doesn't the Decoder recognize this new field and decode it properly? Right now it's ignored
      # tolerations:
      # - key: {{ .MasterTaintKey }}
      #   effect: NoSchedule
      volumes:
      - name: kube-proxy
        configMap:
          name: kube-proxy
      - name: xtables-lock
        hostPath:
          path: /run/xtables.lock
EOF
