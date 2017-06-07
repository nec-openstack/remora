#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_IP=${1:-${NODE_IP}}

ROOT=$(dirname "${BASH_SOURCE}")
if [ -f "${ROOT}/default-env.sh" ]; then
    source ${ROOT}/default-env.sh
fi

bash ${ROOT}/configure-keepalived.sh
bash ${ROOT}/configure-haproxy.sh

systemctl daemon-reload
systemctl enable keepalived
systemctl restart keepalived
systemctl enable haproxy
systemctl restart haproxy
