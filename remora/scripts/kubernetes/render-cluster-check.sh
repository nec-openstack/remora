#!/usr/bin/env bash

set -eu
export LC_ALL=C

TEMPLATE=${KUBE_ASSETS_DIR}/cluster-check.sh

cat <<EOF > ${TEMPLATE}
#!/usr/bin/env bash
set -eu
export LC_ALL=C
ROOT=$(dirname "${BASH_SOURCE}")

CLUSTER_STATUS='pending'
while [[ \${CLUSTER_STATUS} != 'Running' ]]; do
  template="{{range .items}}{{.status.phase}}{{\\"\\n\\"}}{{end}}"
  ${LOCAL_KUBECTL} \\
    -n kube-system \\
    --kubeconfig ${KUBE_ASSETS_DIR}/kubeconfig \\
    get pod -l "tier==control-plane"
  CLUSTER_STATUS=\$(${LOCAL_KUBECTL} \\
    -n kube-system \\
    --kubeconfig ${KUBE_ASSETS_DIR}/kubeconfig \\
    get pod -l "tier==control-plane" -o go-template="\${template}" \\
    | sort | uniq \\
  )
done

echo "All control-planes are running"
EOF
