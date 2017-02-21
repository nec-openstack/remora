#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/env.sh

source ${ROOT}/configure-node.sh etcd ${ETCD_ADDRESS}
source ${ROOT}/configure-node.sh master ${MASTER_ADDRESS}

for WORKER in ${WORKERS_ADDRESS}; do
    source ${ROOT}/configure-node.sh worker ${WORKER}
done
