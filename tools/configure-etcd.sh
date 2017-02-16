#!/usr/bin/env bash

set -eu
export LC_ALL=C

TARGET=$1
TARGET_IP=${TARGET#*@}

readonly ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/util.sh

kube-ssh "${TARGET}" "sudo rm -rf ${KUBE_TEMP}"
kube-ssh "${TARGET}" "mkdir -p ${KUBE_TEMP}"

kube-scp ${TARGET} "${ROOT}/etcd/*" "${KUBE_TEMP}"

kube-ssh "${TARGET}" "sudo bash ${KUBE_TEMP}/configure.sh"
