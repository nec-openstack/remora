#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`

mkdir -p ${LOCAL_CERTS_DIR}

SERVER_SUBJECT=${SERVER_SUBJECT}
SERVER_SANS=${SERVER_SANS}
CA_KEY=${CA_KEY}
CA_CERT=${CA_CERT}
CA_SERIAL=${CA_SERIAL}
SERVER_KEY=${SERVER_KEY}
SERVER_CERT_REQ=${SERVER_CERT_REQ}
SERVER_CERT=${SERVER_CERT}
SERVER_CERT_CONF=${SERVER_CERT_CONF:-"${SERVER_CERT}.cnf"}

# Create config for server's csr
cat > ${SERVER_CERT_CONF} <<EOF
[req]
req_extensions      = v3_req
distinguished_name  = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints    = CA:FALSE
keyUsage            = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage    = clientAuth, serverAuth
subjectAltName      = ${SERVER_SANS}
EOF

if [[ ! -f ${SERVER_KEY} ]]; then
    openssl genrsa -out "${SERVER_KEY}" 4096
fi

openssl req -new -key "${SERVER_KEY}" \
            -out "${SERVER_CERT_REQ}" \
            -subj "${SERVER_SUBJECT}" \
            -config ${SERVER_CERT_CONF}

openssl x509 -req -in "${SERVER_CERT_REQ}" \
             -CA "${CA_CERT}" \
             -CAkey "${CA_KEY}" \
             -CAcreateserial \
             -CAserial "${CA_SERIAL}" \
             -out "${SERVER_CERT}" \
             -days 365 \
             -extensions v3_req \
             -extfile ${SERVER_CERT_CONF}
