#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`
source ${script_dir}/utils.sh
WORKER_IP=${1:-"192.168.1.111"}

CA_KEY=${CA_KEY:-"${LOCAL_CERTS_DIR}/ca-key.pem"}
CA_CERT=${CA_CERT:-"${LOCAL_CERTS_DIR}/ca.pem"}
KUBE_CLIENT_KEY=${KUBE_CLIENT_KEY:-"${LOCAL_CERTS_DIR}/worker-key-${WORKER_IP}.pem"}
KUBE_CLIENT_CERT_REQ=${KUBE_CLIENT_CERT_REQ:-"${LOCAL_CERTS_DIR}/worker-${WORKER_IP}.csr"}
KUBE_CLIENT_CERT=${KUBE_CLIENT_CERT:-"${LOCAL_CERTS_DIR}/worker-${WORKER_IP}.pem"}

openssl genrsa -out "${KUBE_CLIENT_KEY}" 4096
WORKER_IP=${WORKER_IP} \
openssl req -new -key "${KUBE_CLIENT_KEY}" \
            -out "${KUBE_CLIENT_CERT_REQ}" \
            -subj "/CN=kube-worker" \
            -config ${script_dir}/openssl-client.cnf
WORKER_IP=${WORKER_IP} \
openssl x509 -req -in "${KUBE_CLIENT_CERT_REQ}" \
             -CA "${CA_CERT}" \
             -CAkey "${CA_KEY}" \
             -CAcreateserial \
             -out "${KUBE_CLIENT_CERT}" \
             -days 365 \
             -extensions v3_req \
             -extfile ${script_dir}/openssl-client.cnf
