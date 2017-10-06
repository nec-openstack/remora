#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBECONFIG_TEMPLATE=${KUBE_ASSETS_DIR}/kubeconfig
CA_DATA=$(cat ${KUBE_CA_CERT} | base64 | tr -d '\n')
CLIENT_CERTS_DATA=$(cat ${KUBE_ADMIN_CERT} | base64 | tr -d '\n')
CLIENT_KEY_DATA=$(cat ${KUBE_ADMIN_KEY} | base64 | tr -d '\n')

echo "TEMPLATE: $KUBECONFIG_TEMPLATE"
mkdir -p $(dirname $KUBECONFIG_TEMPLATE)
cat << EOF > $KUBECONFIG_TEMPLATE
apiVersion: v1
kind: Config
clusters:
- name: kubernetes
  cluster:
    certificate-authority-data: ${CA_DATA}
    server: https://${KUBE_PUBLIC_SERVICE_IP}:${KUBE_PORT}
users:
- name: admin
  user:
    client-certificate-data: ${CLIENT_CERTS_DATA}
    client-key-data: ${CLIENT_KEY_DATA}
contexts:
- context:
    cluster: kubernetes
    user: admin
  name: admin-context
current-context: admin-context
EOF
