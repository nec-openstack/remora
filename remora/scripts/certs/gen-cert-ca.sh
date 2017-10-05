#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`

mkdir -p ${LOCAL_CERTS_DIR}

CA_KEY=${CA_KEY}
CA_CERT=${CA_CERT}

if [[ ! -f ${CA_KEY} ]]; then
    openssl genrsa -out "${CA_KEY}" 4096
fi
openssl req -x509 -new -nodes \
            -key "${CA_KEY}" \
            -days 10000 \
            -out "${CA_CERT}" \
            -subj "/CN=kube-ca"
