#!/usr/bin/env bash

set -eu
export LC_ALL=C

NODE_IP=$1
ROOT=$(dirname "${BASH_SOURCE}")

mkdir -p ${ETCD_ASSETS_DIR}

source ${ROOT}/render-etcd-certs.sh ${NODE_IP}
source ${ROOT}/render-etcd-server.sh ${NODE_IP}
source ${ROOT}/render-installer.sh
