#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBE_INSTALLER_TEMPLATE=${KUBE_BOOTSTRAP_DIR}/install.sh

mkdir -p $(dirname $KUBE_INSTALLER_TEMPLATE)
cat <<'EOF' > $KUBE_INSTALLER_TEMPLATE
#!/usr/bin/env bash
set -eu
export LC_ALL=C
ROOT=$(dirname "${BASH_SOURCE}")

mkdir -p /etc/kubernetes
cp -r ${ROOT}/kubernetes/* /etc/kubernetes/
EOF
