#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBE_INSTALLER_TEMPLATE=${LOCAL_BOOTSTRAP_ASSETS_DIR}/install.sh

mkdir -p $(dirname $KUBE_INSTALLER_TEMPLATE)
cat <<'EOF' > $KUBE_INSTALLER_TEMPLATE
#!/usr/bin/env bash
set -eu
export LC_ALL=C
ROOT=$(dirname "${BASH_SOURCE}")

mkdir -p /etc/kubernetes/bootstrap
mkdir -p /etc/kubernetes/bootstrap/secrets
mkdir -p /etc/kubernetes/bootstrap/manifests
cp ${ROOT}/haproxy.cfg /etc/kubernetes/bootstrap/
cp ${ROOT}/keepalived.cfg /etc/kubernetes/bootstrap/
cp -r ${ROOT}/certs/* /etc/kubernetes/bootstrap/secrets/
cp -r ${ROOT}/*.yaml /etc/kubernetes/manifests/
EOF
