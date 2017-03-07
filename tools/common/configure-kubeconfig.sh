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
    certificate-authority: /etc/kubernetes/ssl/ca.pem
    server: https://${KUBERNETES_SERVICE_IP}:443
users:
- name: kubelet
  user:
    client-certificate: /etc/kubernetes/ssl/worker.pem
    client-key: /etc/kubernetes/ssl/worker-key.pem
contexts:
- context:
    cluster: kubernetes
    user: kubelet
  name: kubelet-context
current-context: kubelet-context
EOF
