#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_IP=${1:-${NODE_IP}}

ROOT=$(dirname "${BASH_SOURCE}")
if [ -f "${ROOT}/default-env.sh" ]; then
    source ${ROOT}/default-env.sh
fi

mkdir -p /etc/kubernetes/manifests

if [ -f "${ROOT}/configure-certs.sh" ]; then
    # Execute certs plugin
    source ${ROOT}/configure-certs.sh
fi
if [ -f "${ROOT}/configure-hack.sh" ]; then
    source ${ROOT}/configure-hack.sh
fi
if [ -f "${ROOT}/configure-cloud.sh" ]; then
    source ${ROOT}/configure-cloud.sh
fi

source ${ROOT}/configure-kubeconfig.sh
source ${ROOT}/configure-kubelet.sh

systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet
