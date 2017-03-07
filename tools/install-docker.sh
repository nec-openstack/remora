#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh
source ${ROOT}/utils.sh

for MACHINE in ${MACHINES}; do
    TARGET="${NODE_USERNAME}@${MACHINE}"
    kube-ssh "${TARGET}" "curl -sSL https://get.docker.com/ | sh" &
done
