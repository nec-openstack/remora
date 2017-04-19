#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_IP=${1:-${NODE_IP}}

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

mkdir -p /etc/kubernetes/manifests

if [ -f "${ROOT}/configure-certs.sh" ]; then
    # Execute certs plugin
    source ${ROOT}/configure-certs.sh
fi
source ${ROOT}/configure-hack.sh
source ${ROOT}/configure-cloud.sh
source ${ROOT}/configure-kubeconfig.sh
source ${ROOT}/configure-kubelet.sh

systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet
