#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")

export LOCAL_MANIFESTS_DIR=${LOCAL_MANIFESTS_DIR:-${LOCAL_ASSETS_DIR}/manifests}
mkdir -p ${LOCAL_MANIFESTS_DIR}
echo ${LOCAL_MANIFESTS_DIR}

source ${ROOT}/render-apiserver.sh
