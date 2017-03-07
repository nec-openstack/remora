#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")

KUBE_ADDONS_DIR=/etc/kubernetes/addons
mkdir -p ${KUBE_ADDONS_DIR}

cat ${ROOT}/weave-daemonset.yaml > ${KUBE_ADDONS_DIR}/kube-cni-weave.yaml
