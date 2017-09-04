#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBECONFIG_TEMPLATE=/etc/kubernetes/controller-manager.yaml

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
- name: controller-manager
  user:
    client-certificate: ${KUBE_CERTS_DIR}/controller-manager.crt
    client-key: ${KUBE_CERTS_DIR}/controller-manager.key
contexts:
- context:
    cluster: kubernetes
    user: controller-manager
  name: controller-manager-context
current-context: controller-manager-context
EOF
