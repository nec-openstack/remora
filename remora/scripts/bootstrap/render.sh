#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
NODE_IP=$1

export LOCAL_BOOTSTRAP_ASSETS_DIR=${LOCAL_ASSETS_DIR}/bootstrap
mkdir -p ${LOCAL_BOOTSTRAP_ASSETS_DIR}
echo ${LOCAL_BOOTSTRAP_ASSETS_DIR}


source ${ROOT}/render-etcd.sh
source ${ROOT}/render-kubeconfig.sh ${NODE_IP}
source ${ROOT}/render-apiserver.sh
source ${ROOT}/render-controller-manager.sh
source ${ROOT}/render-scheduler.sh
