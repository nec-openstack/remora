#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`

mkdir -p ${LOCAL_CERTS_DIR}

KUBE_SA_KEY=${KUBE_SA_KEY}
KUBE_SA_PUB_KEY=${KUBE_SA_PUB_KEY}

if [[ ! -f ${KUBE_SA_KEY} ]]; then
    openssl genrsa -out "${KUBE_SA_KEY}" 4096
    openssl rsa -pubout -in "${KUBE_SA_KEY}" -out "${KUBE_SA_PUB_KEY}"
fi
