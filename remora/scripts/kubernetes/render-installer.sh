#!/usr/bin/env bash

set -eu
export LC_ALL=C

TEMPLATE=${KUBE_ASSETS_DIR}/install.sh

cat <<EOF > ${TEMPLATE}
#!/usr/bin/env bash
set -eu
export LC_ALL=C
ROOT=$(dirname "${BASH_SOURCE}")

until curl -skf "https://${KUBE_PUBLIC_SERVICE_IP}:${KUBE_PORT}/healthz"
do
    echo "Waiting for Kubernetes API..."
    sleep 5
done

${LOCAL_KUBECTL} \\
  --record \\
  --kubeconfig ${KUBE_ASSETS_DIR}/kubeconfig \\
  apply -R -f ${KUBE_MANIFESTS_DIR}/
EOF
