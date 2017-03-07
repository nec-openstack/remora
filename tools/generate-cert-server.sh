#!/usr/bin/env bash

set -eu
export LC_ALL=C

export KUBERNETES_FQDN=${KUBERNETES_FQDN:-"k8s.example.com"}
export KUBERNETES_SERVICE_IP=${KUBERNETES_SERVICE_IP:-"192.168.1.101"}
MASTER_IP=${1:-"192.168.1.111"}

script_dir=`dirname $0`
source ${script_dir}/utils.sh

CA_KEY=${CA_KEY:-"${LOCAL_CERTS_DIR}/ca-key.pem"}
CA_CERT=${CA_CERT:-"${LOCAL_CERTS_DIR}/ca.pem"}
KUBE_KEY=${KUBE_KEY:-"${LOCAL_CERTS_DIR}/apiserver-key-${MASTER_IP}.pem"}
KUBE_CERT_REQ=${KUBE_CERT_REQ:-"${LOCAL_CERTS_DIR}/apiserver-${MASTER_IP}.csr"}
KUBE_CERT=${KUBE_CERT:-"${LOCAL_CERTS_DIR}/apiserver-${MASTER_IP}.pem"}

openssl genrsa -out "${KUBE_KEY}" 2048
MASTER_IP=${MASTER_IP} \
openssl req -new -key "${KUBE_KEY}" \
            -out "${KUBE_CERT_REQ}" \
            -subj "/CN=kube-server" \
            -config ${script_dir}/openssl-server.cnf

MASTER_IP=${MASTER_IP} \
openssl x509 -req -in "${KUBE_CERT_REQ}" \
             -CA "${CA_CERT}" \
             -CAkey "${CA_KEY}" \
             -CAcreateserial \
             -out "${KUBE_CERT}" \
             -days 365 \
             -extensions v3_req \
             -extfile ${script_dir}/openssl-server.cnf
