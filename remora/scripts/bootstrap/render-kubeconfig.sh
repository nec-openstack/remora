#!/usr/bin/env bash

set -eu
export LC_ALL=C

NODE_IP=$1
KUBECONFIG_TEMPLATE=${LOCAL_BOOTSTRAP_ASSETS_DIR}/kubeconfig-bootstrap.yaml
CA_DATA=$(cat ${LOCAL_CERTS_DIR}/ca.crt | base64)
CLIENT_CERTS_DATA=$(cat ${LOCAL_CERTS_DIR}/admin.crt | base64)
CLIENT_KEY_DATA=$(cat ${LOCAL_CERTS_DIR}/admin.key | base64)

echo "TEMPLATE: $KUBECONFIG_TEMPLATE"
mkdir -p $(dirname $KUBECONFIG_TEMPLATE)
cat << EOF > $KUBECONFIG_TEMPLATE
apiVersion: v1
kind: Config
clusters:
- name: kubernetes
  cluster:
    certificate-authority-data: ${CA_DATA}
    server: https://${NODE_IP}:${KUBE_PORT}
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
