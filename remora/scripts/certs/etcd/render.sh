#!/usr/bin/env bash

set -eu
export LC_ALL=C


ROOT=$(dirname "${BASH_SOURCE}")

export CA_KEY=${ETCD_CA_KEY}
export CA_CERT=${ETCD_CA_CERT}
export CA_SERIAL=${ETCD_CA_SERIAL}

LOCAL_ETCD_CERTS_DIR=${LOCAL_ETCD_CERTS_DIR:-"${LOCAL_CERTS_DIR}/etcd"}
mkdir -p ${LOCAL_ETCD_CERTS_DIR}

source ${ROOT}/render-ca.sh
source ${ROOT}/render-client-cert.sh
