#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_IP=$1

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

mkdir -p /etc/kubernetes/manifests

source ${ROOT}/configure-certs.sh
source ${ROOT}/configure-cloud.sh
source ${ROOT}/configure-kubeconfig.sh
source ${ROOT}/configure-kubelet.sh

systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet
