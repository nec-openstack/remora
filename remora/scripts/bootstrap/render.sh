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

if [[ ${KUBE_CLOUD_PROVIDER} == "openstack" ]]; then
  KUBE_CLOUD_CONFIG_BASENAME=$(basename ${KUBE_CLOUD_CONFIG})
  KUBE_CLOUD_CONFIG_DIRNAME=$(dirname ${KUBE_CLOUD_CONFIG})
  KUBE_CLOUD_CONFIG_MOUNT="
    - mountPath: "${KUBE_CLOUD_CONFIG}"
      name: kube-cloud-config
      subPath: "${KUBE_CLOUD_CONFIG_BASENAME}"
      readOnly: false
"
  KUBE_CLOUD_CONFIG_VOLUME="
  - name: kube-cloud-config
    items:
    - key: "${KUBE_CLOUD_CONFIG_BASENAME}"
      path: "${KUBE_CLOUD_CONFIG_BASENAME}"
    hostPath:
      path: "${KUBE_CLOUD_CONFIG_DIRNAME}"
"
fi

if [[ ${ETCD_SELFHOSTED} == 'true' ]]; then
  source ${ROOT}/render-etcd.sh ${NODE_IP}
fi
source ${ROOT}/render-kubeconfig.sh ${NODE_IP}
source ${ROOT}/render-apiserver.sh ${NODE_IP}
source ${ROOT}/render-keepalived.sh ${NODE_IP}
source ${ROOT}/render-controller-manager.sh ${NODE_IP}
source ${ROOT}/render-scheduler.sh ${NODE_IP}
source ${ROOT}/render-installer.sh ${NODE_IP}
