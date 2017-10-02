#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBECONFIG_TEMPLATE=${LOCAL_KUBELET_ASSETS_DIR}/kubelet.yaml
CA_DATA=$(cat ${LOCAL_CERTS_DIR}/ca.crt | base64)
CLIENT_CERTS_DATA=$(cat ${LOCAL_CERTS_DIR}/kubelet-${NODE_IP}.crt | base64)
CLIENT_KEY_DATA=$(cat ${LOCAL_CERTS_DIR}/kubelet-${NODE_IP}.key | base64)

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
