#!/usr/bin/env bash

set -eu
export LC_ALL=C

address_pattern=${1:-".*"}
ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

bash ${ROOT}/install-k8s-master.sh "${address_pattern}"
bash ${ROOT}/install-k8s-worker.sh "${address_pattern}"
