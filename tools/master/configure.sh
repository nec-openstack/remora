#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_IP=$1
export ETCD_ADDRESS=$2

export ETCD_ENDPOINTS=http://${ETCD_ADDRESS}:2379
export K8S_VER=v1.5.3
export HYPERKUBE_IMAGE_REPO=gcr.io/google_containers/hyperkube

export POD_NETWORK=10.2.0.0/16
export SERVICE_IP_RANGE=10.254.0.0/24
export K8S_SERVICE_IP=10.254.0.1
export DNS_SERVER_IP=10.254.0.10
export API_KEY_PATH=/etc/kubernetes/ssl/apiserver-key.pem

readonly ROOT=$(dirname "${BASH_SOURCE}")

function generate_api_key {
    if [ ! -f ${API_KEY_PATH} ]; then
        mkdir -p $(dirname ${API_KEY_PATH})
        openssl genrsa 4096 > ${API_KEY_PATH}
    fi
}

generate_api_key
source ${ROOT}/configure-api.sh
source ${ROOT}/configure-scheduler.sh
source ${ROOT}/configure-proxy.sh
source ${ROOT}/configure-cm.sh
source ${ROOT}/configure-kubelet.sh
