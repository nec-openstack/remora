#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
NODE_IP=$1

mkdir -p ${KUBE_BOOTSTRAP_DIR}
mkdir -p ${KUBE_BOOTSTRAP_ASSETS_DIR}
mkdir -p ${KUBE_BOOTSTRAP_MANIFESTS_DIR}
mkdir -p ${KUBE_BOOTSTRAP_TEMP_DIR}
mkdir -p ${KUBE_BOOTSTRAP_CERTS_DIR}

if [[ ${ETCD_SELFHOSTED} == 'true' ]]; then
  source ${ROOT}/render-etcd.sh ${NODE_IP}
fi
source ${ROOT}/render-kubeconfig.sh ${NODE_IP}
source ${ROOT}/render-apiserver.sh ${NODE_IP}
source ${ROOT}/render-keepalived.sh ${NODE_IP}
source ${ROOT}/render-controller-manager.sh ${NODE_IP}
source ${ROOT}/render-scheduler.sh ${NODE_IP}
source ${ROOT}/render-installer.sh ${NODE_IP}
