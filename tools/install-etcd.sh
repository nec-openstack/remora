#!/usr/bin/env bash

set -eu
export LC_ALL=C

address_pattern=${1:-".*"}
ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

DISCOVERY_URL=${DISCOVERY_URL:-""}
if [[ ${DISCOVERY_URL} == '' ]]; then
    echo 'Set $DISCOVERY_URL to env.sh (cf: https://discovery.etcd.io/new?size=${cluster_size})'
    exit 1
else
    echo "DISCOVERY_URL: ${DISCOVERY_URL}"
fi

for _ETCD in ${ETCDS}; do
    if [[ ! ${_ETCD} =~ ${address_pattern} ]]; then
        continue
    fi
    echo "Install ETCD: ${_ETCD}"
    source ${ROOT}/configure-node.sh etcd ${_ETCD}
done
