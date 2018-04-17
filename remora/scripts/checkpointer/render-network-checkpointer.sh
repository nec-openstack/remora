#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBE_TEMPLATE=${LOCAL_MANIFESTS_DIR}/network-checkpointer.yaml

cat << EOF > $KUBE_TEMPLATE
---
# FIXME(yuanying): Fix to apply correct ClusterRole
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: remora:network-checkpointer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: network-checkpointer
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: network-checkpointer
  namespace: kube-system
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: network-checkpointer
  namespace: kube-system
  labels:
    tier: control-plane
    k8s-app: network-checkpointer
data:
  kubeconfig: |
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
apiVersion: "apps/v1"
kind: DaemonSet
metadata:
  name: kube-etcd-network-checkpointer
  namespace: kube-system
  labels:
    tier: control-plane
    k8s-app: kube-etcd-network-checkpointer
spec:
  template:
    metadata:
      labels:
        tier: control-plane
        k8s-app: kube-etcd-network-checkpointer
      annotations:
        checkpointer.alpha.coreos.com/checkpoint: "true"
    spec:
      containers:
      - image: quay.io/coreos/kenc:0.0.2
        name: kube-etcd-network-checkpointer
        securityContext:
          privileged: true
        volumeMounts:
        - mountPath: /etc/kubernetes/selfhosted-etcd
          name: checkpoint-dir
          readOnly: false
        - mountPath: /var/etcd
          name: etcd-dir
          readOnly: false
        - mountPath: /var/lock
          name: var-lock
          readOnly: false
        command:
        - /usr/bin/flock
        - /var/lock/kenc.lock
        - -c
        - "kenc -r -m iptables && kenc -m iptables"
      hostNetwork: true
      nodeSelector:
        node-role.kubernetes.io/master: ""
      serviceAccountName: network-checkpointer
      tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      volumes:
      - name: checkpoint-dir
        hostPath:
          path: /etc/kubernetes/checkpoint-iptables
      - name: etcd-dir
        hostPath:
          path: /var/etcd
      - name: var-lock
        hostPath:
          path: /var/lock
  updateStrategy:
    rollingUpdate:
      maxUnavailable: 1
    type: RollingUpdate

EOF
