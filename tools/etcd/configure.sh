#!/usr/bin/env bash

export NODE_IP=${1:-${NODE_IP}}
export _HOSTNAME=$(hostname)

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

source ${ROOT}/configure-etcd.sh
