#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh
source ${ROOT}/utils.sh

for ADDRESS in ${MACHINES}; do
    echo "Install userdata to: ${ADDRESS}"
    TARGET="${NODE_USERNAME}@${ADDRESS}"
    kube-ssh "${TARGET}" "mkdir -p ${KUBE_TEMP_DIR}"
    kube-ssh "${TARGET}" "sudo mkdir -p /var/lib/coreos-install"
    kube-scp "${TARGET}" "${ROOT}/userdata/user_data-${ADDRESS}.yaml" \
                         "${KUBE_TEMP_DIR}/user_data"
    kube-ssh "${TARGET}" "sudo cp ${KUBE_TEMP_DIR}/user_data /var/lib/coreos-install/user_data"
done
