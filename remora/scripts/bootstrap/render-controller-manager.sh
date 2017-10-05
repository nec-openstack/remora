#!/usr/bin/env bash

set -eu
export LC_ALL=C

export KUBE_CM_TEMPLATE=${KUBE_BOOTSTRAP_MANIFESTS_DIR}/kube-controller-manager.bootstrap.yaml
mkdir -p $(dirname $KUBE_CM_TEMPLATE)
cat << EOF > $KUBE_CM_TEMPLATE
---
apiVersion: v1
kind: Pod
metadata:
  name: bootstrap-kube-controller-manager
  namespace: kube-system
spec:
  containers:
  - name: kube-controller-manager
    image: ${KUBE_HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION}
    command:
    - ./hyperkube
    - controller-manager
    - --allocate-node-cidrs=true
    - --cloud-provider=${KUBE_CLOUD_PROVIDER:-""}
    - --cloud-config=${KUBE_CLOUD_CONFIG:-""}
    - --cluster-cidr=${KUBE_CLUSTER_CIDR}
    - --node-cidr-mask-size=${KUBE_NODE_CIDR_MASK_SIZE}
    - --configure-cloud-routes=false
    - --kubeconfig=/etc/kubernetes/bootstrap/kubeconfig-bootstrap
    - --leader-elect=true
    - --root-ca-file=/etc/kubernetes/bootstrap/secrets/kubernetes/ca.crt
    - --cluster-signing-cert-file=/etc/kubernetes/bootstrap/secrets/kubernetes/ca.crt
    - --cluster-signing-key-file=/etc/kubernetes/bootstrap/secrets/kubernetes/ca.key
    - --service-account-private-key-file=/etc/kubernetes/bootstrap/secrets/kubernetes/sa.key
    - --v=${KUBE_LOG_LEVEL:-"2"}
    volumeMounts:
    - name: kubernetes
      mountPath: /etc/kubernetes
      readOnly: true
    - name: ssl-host
      mountPath: /etc/ssl/certs
      readOnly: true
  hostNetwork: true
  volumes:
  - name: kubernetes
    hostPath:
      path: /etc/kubernetes
  - name: ssl-host
    hostPath:
      path: /usr/share/ca-certificates
EOF
