#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBECONFIG_TEMPLATE=${KUBELET_ASSETS_DIR}/kubelet.yaml
CA_DATA=$(cat ${CA_CERT} | base64 | tr -d '\n')
CLIENT_CERTS_DATA=$(cat ${KUBELET_ASSETS_DIR}/kubelet.crt | base64 | tr -d '\n')
CLIENT_KEY_DATA=$(cat ${KUBELET_ASSETS_DIR}/kubelet.key | base64 | tr -d '\n')

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
- name: kubelet
  user:
    client-certificate-data: ${CLIENT_CERTS_DATA}
    client-key-data: ${CLIENT_KEY_DATA}
contexts:
- context:
    cluster: kubernetes
    user: kubelet
  name: kubelet-context
current-context: kubelet-context
EOF
