#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

echo "Install LB: ${LB}"
source ${ROOT}/configure-node.sh lb ${LB}
