#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`
source ${script_dir}/default-env.sh
source ${script_dir}/utils.sh

CA_KEY=${CA_KEY:-"${LOCAL_CERTS_DIR}/ca.key"}
CA_CERT=${CA_CERT:-"${LOCAL_CERTS_DIR}/ca.crt"}
ETCD_KEY=${ETCD_KEY:-"${LOCAL_CERTS_DIR}/etcd.key"}
ETCD_CERT_REQ=${ETCD_CERT_REQ:-"${LOCAL_CERTS_DIR}/etcd.csr"}
ETCD_CERT=${ETCD_CERT:-"${LOCAL_CERTS_DIR}/etcd.crt"}
OPENSSL_CONFIG="${LOCAL_CERTS_DIR}/openssl-etcd-server.cnf"

sans="IP:${ETCD_SERVICE_IP}"
for HOSTNAME in ${ETCD_ADDITIONAL_HOSTNAMES}
do
    sans="${sans},DNS:${HOSTNAME}"
done
for IP in ${ETCD_ADDITIONAL_SERVICE_IPS}
do
    sans="${sans},IP:${IP}"
done
for SERVER in ${ETCDS}
do
    sans="${sans},IP:${SERVER}"
done

# Create config for server's csr
cat > ${OPENSSL_CONFIG} <<EOF
[req]
req_extensions      = v3_req
distinguished_name  = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints    = CA:FALSE
keyUsage            = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage    = serverAuth
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
