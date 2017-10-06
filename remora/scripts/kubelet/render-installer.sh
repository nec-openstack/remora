#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBE_INSTALLER_TEMPLATE=${KUBELET_ASSETS_DIR}/install.sh

mkdir -p $(dirname $KUBE_INSTALLER_TEMPLATE)
cat <<'EOF' > $KUBE_INSTALLER_TEMPLATE
#!/usr/bin/env bash
set -eu
export LC_ALL=C
ROOT=$(dirname "${BASH_SOURCE}")

mkdir -p /etc/kubernetes
cp ${ROOT}/kubelet.yaml /etc/kubernetes/
grep 'certificate-authority-data' /etc/kubernetes/kubelet.yaml | awk '{print $2}' | base64 | tr -d '\n' -d > /etc/kubernetes/ca.crt
cp ${ROOT}/kubelet.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet
EOF
