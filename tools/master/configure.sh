#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_IP=$1

readonly ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/env.sh

function generate_api_key {
    if [ ! -f ${API_KEY_PATH} ]; then
        mkdir -p $(dirname ${API_KEY_PATH})
        openssl genrsa 4096 > ${API_KEY_PATH}
    fi
}

/usr/bin/mkdir -p /etc/kubernetes/manifests

generate_api_key
source ${ROOT}/configure-api.sh
source ${ROOT}/configure-scheduler.sh
source ${ROOT}/configure-proxy.sh
source ${ROOT}/configure-cm.sh
source ${ROOT}/configure-kubelet.sh
