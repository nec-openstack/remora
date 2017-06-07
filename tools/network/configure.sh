#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_IP=${1:-${NODE_IP}}

ROOT=$(dirname "${BASH_SOURCE}")
if [ -f "${ROOT}/default-env.sh" ]; then
    source ${ROOT}/default-env.sh
fi

# Network plugin
plugin_name='kubenet'
if [[ ${KUBE_NETWORK_PLUGIN} == 'cni' ]]; then
    plugin_name=${KUBE_CNI_PLUGIN}
fi

source ${ROOT}/configure-${plugin_name}.sh
