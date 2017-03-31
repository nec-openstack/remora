#!/usr/bin/env bash

set -eu
export LC_ALL=C

address_pattern=${1:-".*"}
ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

for _ETCD in ${ETCD_PROXIES}; do
    if [[ ! ${_ETCD} =~ ${address_pattern} ]]; then
        continue
    fi
    echo "Install ETCD_PROXY: ${_ETCD}"
    source ${ROOT}/configure-node.sh etcd-proxy ${_ETCD}
done
