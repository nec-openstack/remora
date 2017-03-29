#!/usr/bin/env bash

set -eu
export LC_ALL=C

address_pattern=${1:-".*"}
ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

echo
echo '**** Please setup valid following variables...'
echo '    -   ${NODE_NETWORK_RANGE}'
echo '    -   ${NODE_NET_DEVICE}'
echo

for MASTER in ${MASTERS}; do
    if [[ ! ${MASTER} =~ ${address_pattern} ]]; then
        continue
    fi
    echo "Install keepalived to Master Node: ${MASTER}"
    source ${ROOT}/configure-node.sh keepalived ${MASTER}
    echo "Install HAProxy to Master Node: ${MASTER}"
    source ${ROOT}/configure-node.sh lb ${LB}
done
