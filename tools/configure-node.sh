#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh
source ${ROOT}/utils.sh

TYPE=$1
TARGET_IP=$2
TARGET=${NODE_USERNAME}@${TARGET_IP}

kube-ssh "${TARGET}" "sudo rm -rf ${KUBE_TEMP}"
kube-ssh "${TARGET}" "mkdir -p ${KUBE_TEMP}"

kube-scp ${TARGET} "${ROOT}/default-env.sh" "${KUBE_TEMP}"
if [ -f "${ROOT}/env.sh" ]; then
  kube-scp ${TARGET} "${ROOT}/env.sh" "${KUBE_TEMP}"
fi
kube-scp ${TARGET} "${ROOT}/common/*" "${KUBE_TEMP}"
kube-scp ${TARGET} "${ROOT}/${TYPE}/*" "${KUBE_TEMP}"

if [ -f "${ROOT}/pre_configure_${TYPE}.sh" ]; then
  bash "${ROOT}/pre_configure_${TYPE}.sh" ${TARGET_IP}
fi

kube-ssh "${TARGET}" "sudo bash ${KUBE_TEMP}/configure.sh ${TARGET_IP}"
