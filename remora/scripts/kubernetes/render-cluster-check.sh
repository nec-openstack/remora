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
while [ \${CLUSTER_STATUS} = 'pending' ]; do
  template="{{range .items}}{{.status.phase}}{{\\"\\n\\"}}{{end}}"
  ${LOCAL_KUBECTL} \\
    -n kube-system \\
    --kubeconfig ${KUBE_ASSETS_DIR}/kubeconfig \\
    get pod -l "tier==control-plane"
  result_status=\$(${LOCAL_KUBECTL} \\
    -n kube-system \\
    --kubeconfig ${KUBE_ASSETS_DIR}/kubeconfig \\
    get pod -l "tier==control-plane" -o go-template="\${template}" \\
    | sort | uniq \\
  )
  echo \${result_status}
  count=\$(echo \${result_status} | wc -l)
  if [ \${count} = 1 ] ; then
    if [ \${result_status} = 'Running' ] ; then
      CLUSTER_STATUS='Running'
    fi
  else
    echo "Checking..."
    sleep 5
  fi
done

echo "All control-planes are running"
EOF
