#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBECONFIG_TEMPLATE=/etc/kubernetes/kubelet.yaml

echo "TEMPLATE: $KUBECONFIG_TEMPLATE"
mkdir -p $(dirname $KUBECONFIG_TEMPLATE)
cat << EOF > $KUBECONFIG_TEMPLATE
apiVersion: v1
kind: Config
clusters:
- name: kubernetes
  cluster:
    certificate-authority: ${KUBE_CERTS_DIR}/ca.crt
    server: https://${KUBE_PUBLIC_SERVICE_IP}:${KUBE_PORT}
users:
- name: kubelet
  user:
    client-certificate: ${KUBE_CERTS_DIR}/kubelet.crt
    client-key: ${KUBE_CERTS_DIR}/kubelet.key
contexts:
- context:
    cluster: kubernetes
    user: kubelet
  name: kubelet-context
current-context: kubelet-context
EOF
