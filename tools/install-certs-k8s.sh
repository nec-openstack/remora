#!/usr/bin/env bash

set -eu
export LC_ALL=C

address_pattern=${1:-".*"}
ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh
source ${ROOT}/utils.sh

export CERTS_REMOTE_DIR=${KUBE_CERTS_DIR:-"/etc/kubernetes/pki"}
export CERTS_TEMP_REMOTE_DIR="${KUBE_TEMP_DIR}/certs"

K8S_CLUSTER="${MASTERS} ${WORKERS}"
for NODE in ${K8S_CLUSTER}
do
    create-certs-dir ${NODE}
    install-cert ${NODE} ca
    install-client-certs ${NODE} kubelet

    if contains ${NODE} ${MASTERS}; then
        install-client-certs ${NODE} admin
    fi

    if contains ${NODE} ${KUBE_APISERVERS}; then
        install-public-key ${NODE} sa
        install-server-certs ${NODE} apiserver
        install-client-certs ${NODE} apiserver-kubelet-client
    fi

    if contains ${NODE} ${KUBE_CONTROLLER_MANAGERS}; then
        install-private-key ${NODE} sa
        install-private-key ${NODE} ca
        install-client-certs ${NODE} controller-manager
    fi

    if contains ${NODE} ${KUBE_SCHEDULERS}; then
        install-client-certs ${NODE} scheduler
    fi

done
