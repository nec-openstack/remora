#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")

mkdir -p ${KUBE_ASSETS_DIR}

source ${ROOT}/render-kubeconfig.sh
source ${ROOT}/render-installer.sh
source ${ROOT}/render-cluster-check.sh
