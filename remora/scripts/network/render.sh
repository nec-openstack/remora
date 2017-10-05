#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")

export LOCAL_MANIFESTS_DIR=${KUBE_MANIFESTS_DIR}
mkdir -p ${LOCAL_MANIFESTS_DIR}
echo ${LOCAL_MANIFESTS_DIR}

# Network plugin
plugin_name='kubenet'
if [[ ${KUBE_NETWORK_PLUGIN} == 'cni' ]]; then
    plugin_name=${KUBE_CNI_PLUGIN}
fi

source ${ROOT}/render-${plugin_name}.sh
