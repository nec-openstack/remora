#!/usr/bin/env bash

# ## for apiserver-kubelet-client
# $ bash tools/gen-cert-client ${CLIENT_IP} \
#       apiserver-kubelet-client \
#       "/O=system:masters/CN=kube-apiserver-kubelet-client"
#
# ## for etcd-client
# $ bash tools/gen-cert-client ${CLIENT_IP} \
#       etcd-client \
#       "/CN=etcd-client"
#
# ## for controller-manager
# $ bash tools/gen-cert-client ${CLIENT_IP} \
#       controller-manager \
#       "/CN=system:kube-controller-manager"
#
# ## for scheduler
# $ bash tools/gen-cert-client ${CLIENT_IP} \
#       scheduler \
#       "/CN=system:kube-scheduler"
#
# ## for kubelet
# $ bash tools/gen-cert-client ${CLIENT_IP} \
#       kubelet \
#       "/O=system:nodes/CN=system:node:kubelet-${CLIENT_IP//'.'/'-'}"
#
# ## for admin
# $ bash tools/gen-cert-client ${CLIENT_IP} \
#       admin \
#       "/O=system:masters/CN=kubernetes-admin"
#

set -eu
export LC_ALL=C

script_dir=`dirname $0`
CLIENT_IP=${1:-"192.168.1.111"}
PREFIX=${2:-"client"}
SUBJECT=${3:-"/CN=client"}

CA_KEY=${CA_KEY:-"${LOCAL_CERTS_DIR}/ca.key"}
CA_CERT=${CA_CERT:-"${LOCAL_CERTS_DIR}/ca.crt"}
CLIENT_KEY=${CLIENT_KEY:-"${LOCAL_CERTS_DIR}/${PREFIX}-${CLIENT_IP}.key"}
CLIENT_CERT_REQ=${CLIENT_CERT_REQ:-"${LOCAL_CERTS_DIR}/${PREFIX}-${CLIENT_IP}.csr"}
CLIENT_CERT=${CLIENT_CERT:-"${LOCAL_CERTS_DIR}/${PREFIX}-${CLIENT_IP}.crt"}

if [[ ! -f ${CLIENT_KEY} ]]; then
    openssl genrsa -out "${CLIENT_KEY}" 4096
fi

openssl req -new -key "${CLIENT_KEY}" \
            -out "${CLIENT_CERT_REQ}" \
            -subj "${SUBJECT}" \
            -config ${script_dir}/openssl-client.cnf

openssl x509 -req -in "${CLIENT_CERT_REQ}" \
             -CA "${CA_CERT}" \
             -CAkey "${CA_KEY}" \
             -CAcreateserial \
             -out "${CLIENT_CERT}" \
             -days 365 \
             -extensions v3_req \
             -extfile ${script_dir}/openssl-client.cnf
