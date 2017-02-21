#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_IP=$1

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/env.sh

mkdir -p /etc/kubernetes/manifests

source ${ROOT}/configure-cloud.sh
source ${ROOT}/configure-proxy.sh
source ${ROOT}/configure-kubelet.sh

systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet
