#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_IP=$1

readonly ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/env.sh

/usr/bin/mkdir -p /etc/kubernetes/manifests

source ${ROOT}/configure-proxy.sh
source ${ROOT}/configure-kubelet.sh
