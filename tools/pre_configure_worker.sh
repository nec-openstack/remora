#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh
source ${ROOT}/utils.sh

TARGET_IP=$1
TARGET=${NODE_USERNAME}@${TARGET_IP}

# Certs plugin
kube-scp ${TARGET} "${ROOT}/plugins/certs/configure-noops.sh" \
                   "${KUBE_TEMP}/configure-certs.sh"
