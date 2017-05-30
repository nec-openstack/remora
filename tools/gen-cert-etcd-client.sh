#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`
source ${script_dir}/default-env.sh
source ${script_dir}/utils.sh
CLIENT_IP=${1:-"192.168.1.111"}

CA_KEY=${CA_KEY:-"${LOCAL_CERTS_DIR}/ca.key"}
CA_CERT=${CA_CERT:-"${LOCAL_CERTS_DIR}/ca.crt"}
ETCD_CLIENT_KEY=${ETCD_CLIENT_KEY:-"${LOCAL_CERTS_DIR}/etcd-client-${CLIENT_IP}.key"}
ETCD_CLIENT_CERT_REQ=${ETCD_CLIENT_CERT_REQ:-"${LOCAL_CERTS_DIR}/etcd-client-${CLIENT_IP}.csr"}
ETCD_CLIENT_CERT=${ETCD_CLIENT_CERT:-"${LOCAL_CERTS_DIR}/etcd-client-${CLIENT_IP}.crt"}

if [[ ! -f ${ETCD_CLIENT_KEY} ]]; then
    openssl genrsa -out "${ETCD_CLIENT_KEY}" 4096
fi

openssl req -new -key "${ETCD_CLIENT_KEY}" \
            -out "${ETCD_CLIENT_CERT_REQ}" \
            -subj "/CN=etcd-client-${CLIENT_IP//./-}" \
            -config ${script_dir}/openssl-client.cnf

openssl x509 -req -in "${ETCD_CLIENT_CERT_REQ}" \
             -CA "${CA_CERT}" \
             -CAkey "${CA_KEY}" \
             -CAcreateserial \
             -out "${ETCD_CLIENT_CERT}" \
             -days 365 \
             -extensions v3_req \
             -extfile ${script_dir}/openssl-client.cnf
