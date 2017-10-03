#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_IP=${1:-${NODE_IP}}

ROOT=$(dirname "${BASH_SOURCE}")
if [ -f "${ROOT}/default-env.sh" ]; then
    source ${ROOT}/default-env.sh
fi

export LOCAL_KUBELET_ASSETS_DIR=${LOCAL_KUBELET_ASSETS_DIR:-${LOCAL_ASSETS_DIR}/kubelet/node-${NODE_IP}}
mkdir -p ${LOCAL_KUBELET_ASSETS_DIR}
echo ${LOCAL_KUBELET_ASSETS_DIR}


source ${ROOT}/render-cloud.sh
source ${ROOT}/render-kubeconfig.sh
source ${ROOT}/render-kubelet.sh
source ${ROOT}/render-installer.sh
