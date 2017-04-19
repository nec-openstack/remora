#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/utils.sh

TARGET_IP=$1
TARGET=${NODE_USERNAME}@${TARGET_IP}

# Network plugin
plugin_name='kubenet'
if [[ ${KUBE_NETWORK_PLUGIN} == 'cni' ]]; then
    plugin_name=${KUBE_CNI_PLUGIN}
fi
kube-scp ${TARGET} "${ROOT}/plugins/network/configure-${plugin_name}.sh" \
                   "${KUBE_TEMP}/configure-network.sh"

# Certs plugin
kube-scp ${TARGET} "${ROOT}/plugins/certs/configure-noops.sh" \
                   "${KUBE_TEMP}/configure-certs.sh"
