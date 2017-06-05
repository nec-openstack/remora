#!/usr/bin/env bash

set -eu
export LC_ALL=C

address_pattern=${1:-".*"}
ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh
source ${ROOT}/utils.sh

export CERTS_REMOTE_DIR=${ETCD_CERTS_DIR:-"/etc/kubernetes/pki"}
export CERTS_TEMP_REMOTE_DIR="${KUBE_TEMP_DIR}/certs"

for NODE in ${ETCDS}
do
    if [[ ! ${NODE} =~ ${address_pattern} ]]; then
        continue
    fi
    create-certs-dir ${NODE}
    install-cert ${NODE} ca
    install-client-certs ${NODE} etcd
done

for NODE in ${ETCD_PROXIES}
do
    if [[ ! ${NODE} =~ ${address_pattern} ]]; then
        continue
    fi
    create-certs-dir ${NODE}
    install-cert ${NODE} ca
    install-client-certs ${NODE} etcd-client
done
