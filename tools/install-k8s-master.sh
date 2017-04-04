#!/usr/bin/env bash

set -eu
export LC_ALL=C

address_pattern=${1:-".*"}
ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

for MASTER in ${MASTERS}; do
    if [[ ! ${MASTER} =~ ${address_pattern} ]]; then
        continue
    fi
    echo "Install Master Node: ${MASTER}"
    source ${ROOT}/configure-node.sh master ${MASTER}
done
