#!/usr/bin/env bash

set -eu
export LC_ALL=C

address_pattern=${1:-".*"}
ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

for WORKER in ${WORKERS}; do
    if [[ ! ${WORKER} =~ ${address_pattern} ]]; then
        continue
    fi
    echo "Install Worker Node: ${WORKER}"
    source ${ROOT}/configure-node.sh worker ${WORKER}
done
