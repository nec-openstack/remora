#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBECONFIG_TEMPLATE=/etc/kubernetes/scheduler.yaml

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
- name: scheduler
  user:
    client-certificate: ${KUBE_CERTS_DIR}/scheduler.crt
    client-key: ${KUBE_CERTS_DIR}/scheduler.key
contexts:
- context:
    cluster: kubernetes
    user: scheduler
  name: scheduler-context
current-context: scheduler-context
EOF
