#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`

mkdir -p ${LOCAL_CERTS_DIR}

CA_KEY=${CA_KEY:-"${LOCAL_CERTS_DIR}/ca.key"}
CA_CERT=${CA_CERT:-"${LOCAL_CERTS_DIR}/ca.crt"}
ETCD_KEY=${ETCD_KEY:-"${LOCAL_CERTS_DIR}/etcd.key"}
ETCD_CERT_REQ=${ETCD_CERT_REQ:-"${LOCAL_CERTS_DIR}/etcd.csr"}
ETCD_CERT=${ETCD_CERT:-"${LOCAL_CERTS_DIR}/etcd.crt"}
OPENSSL_CONFIG="${LOCAL_CERTS_DIR}/etcd-server.cnf"

sans="DNS:*.kube-etcd.kube-system.svc.cluster.local,DNS:kube-etcd-client.kube-system.svc.cluster.local"
sans="${sans},DNS:localhost,IP:127.0.0.1"
sans="${sans},IP:${ETCD_CLUSTER_IP},IP:${ETCD_BOOTSTRAP_CLUSTER_IP}"

# Create config for server's csr
cat > ${OPENSSL_CONFIG} <<EOF
[req]
req_extensions      = v3_req
distinguished_name  = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints    = CA:FALSE
keyUsage            = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage    = clientAuth, serverAuth
subjectAltName      = ${sans}
EOF

if [[ ! -f ${ETCD_KEY} ]]; then
    openssl genrsa -out "${ETCD_KEY}" 4096
fi

openssl req -new -key "${ETCD_KEY}" \
            -out "${ETCD_CERT_REQ}" \
            -subj "/CN=etcd-server" \
            -config ${OPENSSL_CONFIG}

openssl x509 -req -in "${ETCD_CERT_REQ}" \
             -CA "${CA_CERT}" \
             -CAkey "${CA_KEY}" \
             -CAcreateserial \
             -out "${ETCD_CERT}" \
             -days 365 \
             -extensions v3_req \
             -extfile ${OPENSSL_CONFIG}
