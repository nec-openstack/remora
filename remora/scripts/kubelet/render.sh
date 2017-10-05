#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_IP=${1:-${NODE_IP}}

ROOT=$(dirname "${BASH_SOURCE}")

mkdir -p ${KUBELET_ASSETS_DIR}


source ${ROOT}/render-cert-kubelet.sh "/O=system:nodes/CN=system:node:${NODE_IP}"
source ${ROOT}/render-cloud.sh
source ${ROOT}/render-kubeconfig.sh
source ${ROOT}/render-kubelet.sh
source ${ROOT}/render-installer.sh
