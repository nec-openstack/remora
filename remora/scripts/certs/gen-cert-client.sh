#!/usr/bin/env bash

# ## for kubelet-client
# $ bash tools/gen-cert-client \
#       kubelet-client \
#       "/O=system:masters/CN=kube-kubelet-client"
#
# ## for etcd-client
# $ bash tools/gen-cert-client \
#       etcd-client \
#       "/CN=etcd-client"
#
# ## for controller-manager
# $ bash tools/gen-cert-client \
#       controller-manager \
#       "/CN=system:kube-controller-manager"
#
# ## for scheduler
# $ bash tools/gen-cert-client \
#       scheduler \
#       "/CN=system:kube-scheduler"
# ## for admin
# $ bash tools/gen-cert-client \
#       admin \
#       "/O=system:masters/CN=kubernetes-admin"
#

set -eu
export LC_ALL=C

script_dir=`dirname $0`
PREFIX=${1:-"client"}
SUBJECT=${2:-"/CN=client"}

mkdir -p ${LOCAL_CERTS_DIR}

CA_KEY=${CA_KEY}
CA_CERT=${CA_CERT}
CA_SERIAL=${CA_SERIAL}
CLIENT_KEY=${CLIENT_KEY}
CLIENT_CERT_REQ=${CLIENT_CERT_REQ}
CLIENT_CERT=${CLIENT_CERT}

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
             -CAserial "${CA_SERIAL}" \
             -out "${CLIENT_CERT}" \
             -days 365 \
             -extensions v3_req \
             -extfile ${script_dir}/../openssl-client.cnf
