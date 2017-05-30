#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`
source ${script_dir}/utils.sh

CA_KEY=${CA_KEY:-"${LOCAL_CERTS_DIR}/ca.key"}
CA_CERT=${CA_CERT:-"${LOCAL_CERTS_DIR}/ca.crt"}
KUBE_KEY=${KUBE_KEY:-"${LOCAL_CERTS_DIR}/apiserver-key.pem"}
KUBE_CERT_REQ=${KUBE_CERT_REQ:-"${LOCAL_CERTS_DIR}/apiserver.csr"}
KUBE_CERT=${KUBE_CERT:-"${LOCAL_CERTS_DIR}/apiserver.pem"}
OPENSSL_CONFIG="${LOCAL_CERTS_DIR}/openssl-server.cnf"

sans="DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.cluster.local"
sans="${sans},IP:${KUBERNETES_SERVICE_IP},IP:${KUBE_INTERNAL_SERVICE_IP}"
for HOSTNAME in ${KUBE_ADDITIONAL_HOSTNAMES}
do
    sans="${sans},DNS:${HOSTNAME}"
done
for IP in ${KUBE_ADDITIONAL_SERVICE_IPS}
do
    sans="${sans},IP:${IP}"
done
for SERVER in ${SERVERS}
do
    sans="${sans},IP:${SERVER}"
done

# Create config for server's csr
cat > ${LOCAL_CERTS_DIR}/openssl-server.cnf <<EOF
[req]
req_extensions      = v3_req
distinguished_name  = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints    = CA:FALSE
keyUsage            = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName      = ${sans}
EOF


if [[ ! -f ${KUBE_KEY} ]]; then
    openssl genrsa -out "${KUBE_KEY}" 4096
fi
openssl req -new -key "${KUBE_KEY}" \
            -out "${KUBE_CERT_REQ}" \
            -subj "/CN=kube-server" \
            -config ${LOCAL_CERTS_DIR}/openssl-server.cnf

openssl x509 -req -in "${KUBE_CERT_REQ}" \
             -CA "${CA_CERT}" \
             -CAkey "${CA_KEY}" \
             -CAcreateserial \
             -out "${KUBE_CERT}" \
             -days 365 \
             -extensions v3_req \
             -extfile ${LOCAL_CERTS_DIR}/openssl-server.cnf
