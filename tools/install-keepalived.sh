#!/usr/bin/env bash

set -eu
export LC_ALL=C

address_pattern=${1:-".*"}
ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

echo 'Please setup correct ${NODE_NETWORK_RANGE} and ${NODE_NET_DEVICE} variables.'

for MASTER in ${MASTERS}; do
    if [[ ! ${MASTER} =~ ${address_pattern} ]]; then
        continue
    fi
    echo "Install keepalived to Master Node: ${MASTER}"
    source ${ROOT}/configure-node.sh keepalived ${MASTER}
done
