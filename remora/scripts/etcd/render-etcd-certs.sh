#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
export NODE_IP=${1}

cp ${ETCD_CA_CERT} ${ETCD_ASSETS_DIR}/

export CA_KEY=${ETCD_CA_KEY}
export CA_CERT=${ETCD_CA_CERT}
export CA_SERIAL=${ETCD_CA_SERIAL}
export SERVER_SUBJECT="/CN=${ETCD_NODE_NAME}"
export SERVER_KEY=${ETCD_SERVER_KEY}
export SERVER_CERT_REQ=${ETCD_SERVER_CERT_REQ}
export SERVER_CERT=${ETCD_SERVER_CERT}

SERVER_SANS="IP:${NODE_IP}"
SERVER_SANS="${SERVER_SANS},DNS:*.kube-etcd.kube-system.svc.cluster.local,DNS:kube-etcd-client.kube-system.svc.cluster.local"
SERVER_SANS="${SERVER_SANS},DNS:localhost,IP:127.0.0.1"
SERVER_SANS="${SERVER_SANS},IP:${ETCD_CLUSTER_IP},IP:${ETCD_BOOTSTRAP_CLUSTER_IP}"
export SERVER_SANS

bash ${ROOT}/../certs/gen-cert-server.sh
