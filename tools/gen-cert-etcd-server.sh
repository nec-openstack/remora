#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`
source ${script_dir}/default-env.sh
source ${script_dir}/utils.sh
NODE_IP=${1:-"192.168.1.111"}

CA_KEY=${CA_KEY:-"${LOCAL_CERTS_DIR}/ca.key"}
CA_CERT=${CA_CERT:-"${LOCAL_CERTS_DIR}/ca.crt"}
ETCD_KEY=${ETCD_KEY:-"${LOCAL_CERTS_DIR}/etcd-${NODE_IP}.key"}
ETCD_CERT_REQ=${ETCD_CERT_REQ:-"${LOCAL_CERTS_DIR}/etcd-${NODE_IP}.csr"}
ETCD_CERT=${ETCD_CERT:-"${LOCAL_CERTS_DIR}/etcd-${NODE_IP}.crt"}
OPENSSL_CONFIG="${script_dir}/openssl-server-client.cnf"

if [[ ! -f ${ETCD_KEY} ]]; then
    openssl genrsa -out "${ETCD_KEY}" 4096
fi

NODE_IP=${NODE_IP} \
openssl req -new -key "${ETCD_KEY}" \
            -out "${ETCD_CERT_REQ}" \
            -subj "/CN=etcd-server" \
            -config ${OPENSSL_CONFIG}

NODE_IP=${NODE_IP} \
openssl x509 -req -in "${ETCD_CERT_REQ}" \
             -CA "${CA_CERT}" \
             -CAkey "${CA_KEY}" \
             -CAcreateserial \
             -out "${ETCD_CERT}" \
             -days 365 \
             -extensions v3_req \
             -extfile ${OPENSSL_CONFIG}
