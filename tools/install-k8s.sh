#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

for MASTER in ${MASTERS}; do
    echo "Install Master Node: ${MASTER}"
    source ${ROOT}/configure-node.sh master ${MASTER}
done

for WORKER in ${WORKERS}; do
    echo "Install Worker Node: ${WORKER}"
    source ${ROOT}/configure-node.sh worker ${WORKER}
done
