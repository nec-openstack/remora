#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

echo "Install ETCD: ${ETCD}"
source ${ROOT}/configure-node.sh etcd ${ETCD}
