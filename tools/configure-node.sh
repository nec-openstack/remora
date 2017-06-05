#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh
source ${ROOT}/utils.sh

TYPE=$1
TARGET_IP=$2
TARGET=${NODE_USERNAME}@${TARGET_IP}

kube-ssh "${TARGET}" "sudo rm -rf ${KUBE_TEMP_DIR}"
kube-ssh "${TARGET}" "mkdir -p ${KUBE_TEMP_DIR}"

kube-scp ${TARGET} "${ROOT}/default-env.sh" "${KUBE_TEMP_DIR}"
if [ -f "${ROOT}/env.sh" ]; then
  kube-scp ${TARGET} "${ROOT}/env.sh" "${KUBE_TEMP_DIR}"
fi
if [ -f "${ROOT}/env.${CLUSTER_NAME}.sh" ]; then
  kube-scp ${TARGET} "${ROOT}/env.${CLUSTER_NAME}.sh" "${KUBE_TEMP_DIR}"
fi
kube-scp ${TARGET} "${ROOT}/common/*" "${KUBE_TEMP_DIR}"
kube-scp ${TARGET} "${ROOT}/${TYPE}/*" "${KUBE_TEMP_DIR}"

if [ -f "${ROOT}/pre_configure_${TYPE}.sh" ]; then
  bash "${ROOT}/pre_configure_${TYPE}.sh" ${TARGET_IP}
fi

kube-ssh "${TARGET}" "sudo CLUSTER_NAME=${CLUSTER_NAME} bash ${KUBE_TEMP_DIR}/configure.sh ${TARGET_IP}"
