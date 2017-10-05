#!/usr/bin/env bash

set -eu
export LC_ALL=C

NODE_IP=$1
KUBECONFIG_TEMPLATE=${KUBE_BOOTSTRAP_TEMP_DIR}/kubeconfig-bootstrap
CA_DATA=$(cat ${KUBE_CA_CERT} | base64)
CLIENT_CERTS_DATA=$(cat ${KUBE_ADMIN_CERT} | base64)
CLIENT_KEY_DATA=$(cat ${KUBE_ADMIN_KEY} | base64)

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
