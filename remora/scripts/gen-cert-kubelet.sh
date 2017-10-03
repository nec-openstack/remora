#!/usr/bin/env bash

# ## for kubelet
# $ bash tools/gen-cert-client ${NODE_IP} \
#       kubelet \
#       "/O=system:nodes/CN=system:node:kubelet-${NODE_IP//'.'/'-'}"

set -eu
export LC_ALL=C

script_dir=`dirname $0`
NODE_IP=${1:-"192.168.1.111"}
PREFIX=${2:-"client"}
SUBJECT=${3:-"/CN=client"}

mkdir -p ${LOCAL_CERTS_DIR}

CA_KEY=${CA_KEY:-"${LOCAL_CERTS_DIR}/ca.key"}
CA_CERT=${CA_CERT:-"${LOCAL_CERTS_DIR}/ca.crt"}
CLIENT_KEY=${CLIENT_KEY:-"${LOCAL_CERTS_DIR}/${PREFIX}-${NODE_IP}.key"}
CLIENT_CERT_REQ=${CLIENT_CERT_REQ:-"${LOCAL_CERTS_DIR}/${PREFIX}-${NODE_IP}.csr"}
CLIENT_CERT=${CLIENT_CERT:-"${LOCAL_CERTS_DIR}/${PREFIX}-${NODE_IP}.crt"}
mkdir -p $(dirname $CLIENT_KEY)
mkdir -p $(dirname $CLIENT_CERT_REQ)
mkdir -p $(dirname $CLIENT_CERT)

if [[ ! -f ${CLIENT_KEY} ]]; then
    openssl genrsa -out "${CLIENT_KEY}" 4096
fi

NODE_IP=${NODE_IP} \
openssl req -new -key "${CLIENT_KEY}" \
            -out "${CLIENT_CERT_REQ}" \
            -subj "${SUBJECT}" \
            -config ${script_dir}/openssl-client.cnf

NODE_IP=${NODE_IP} \
openssl x509 -req -in "${CLIENT_CERT_REQ}" \
             -CA "${CA_CERT}" \
             -CAkey "${CA_KEY}" \
             -CAcreateserial \
             -out "${CLIENT_CERT}" \
             -days 365 \
             -extensions v3_req \
             -extfile ${script_dir}/openssl-client.cnf
