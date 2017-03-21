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
kube-ssh "${TARGET}" "sudo systemctl stop docker && sudo systemctl disable docker"
kube-ssh "${TARGET}" "sudo rm -rf /var/lib/docker"
kube-ssh "${TARGET}" "sudo rm -f /etc/systemd/system/kubelet.service"
kube-ssh "${TARGET}" "sudo rm -rf /etc/kubernetes/manifests"
kube-ssh "${TARGET}" "sudo rm -f /etc/kubernetes/kubelet.yaml"

kube-ssh "${TARGET}" "sudo systemctl enable docker && sudo systemctl start docker"
