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
source ${ROOT}/configure-api.sh
source ${ROOT}/configure-scheduler.sh
source ${ROOT}/configure-cm.sh
source ${ROOT}/configure-kubelet.sh

source ${ROOT}/configure-proxy.sh
source ${ROOT}/configure-dns.sh

while ! curl -sf ${ETCD_ENDPOINT}/v2/machines; do
    echo "Waiting for etcd.."
    sleep 5
done

systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet

until curl -sf "http://127.0.0.1:8080/healthz"
do
    echo "Waiting for Kubernetes API..."
    sleep 5
done

source ${ROOT}/configure-addons.sh
source ${ROOT}/configure-network.sh
