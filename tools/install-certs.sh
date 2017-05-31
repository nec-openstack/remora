#!/usr/bin/env bash

set -eu
export LC_ALL=C

address_pattern=${1:-".*"}
ROOT=$(dirname "${BASH_SOURCE}")

bash ${ROOT}/install-certs-etcd.sh ${address_pattern}
bash ${ROOT}/install-certs-k8s.sh ${address_pattern}
