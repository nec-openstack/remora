#!/usr/bin/env bash

# ## for kubelet
# $ bash tools/gen-cert-client \
#       "/O=system:nodes/CN=system:node:kubelet-${NODE_IP//'.'/'-'}"

set -eu
export LC_ALL=C

script_dir=`dirname $0`
SUBJECT=${1:-"/CN=client"}

mkdir -p ${LOCAL_CERTS_DIR}

CA_KEY=${KUBE_CA_KEY}
CA_CERT=${KUBE_CA_CERT}
CLIENT_KEY=${KUBELET_CLIENT_KEY}
CLIENT_CERT_REQ=${KUBELET_CLIENT_CERT_REQ}
CLIENT_CERT=${KUBELET_CLIENT_CERT}

if [[ ! -f ${CLIENT_KEY} ]]; then
    openssl genrsa -out "${CLIENT_KEY}" 4096
fi

openssl req -new -key "${CLIENT_KEY}" \
            -out "${CLIENT_CERT_REQ}" \
            -subj "${SUBJECT}" \
            -config ${script_dir}/../openssl-client.cnf

openssl x509 -req -in "${CLIENT_CERT_REQ}" \
             -CA "${CA_CERT}" \
             -CAkey "${CA_KEY}" \
             -CAcreateserial \
             -out "${CLIENT_CERT}" \
             -days 365 \
             -extensions v3_req \
             -extfile ${script_dir}/../openssl-client.cnf
