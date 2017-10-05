#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")

export LOCAL_MANIFESTS_DIR=${KUBE_MANIFESTS_DIR}
export LOCAL_ETCD_MIGRATE_DIR=${LOCAL_ETCD_MIGRATE_DIR:-${LOCAL_ASSETS_DIR}/etcd}
mkdir -p ${LOCAL_MANIFESTS_DIR}
mkdir -p ${LOCAL_ETCD_MIGRATE_DIR}
echo ${LOCAL_MANIFESTS_DIR}
echo ${LOCAL_ETCD_MIGRATE_DIR}

source ${ROOT}/render-etcd-assets.sh
source ${ROOT}/render-etcd-operator.sh
source ${ROOT}/render-etcd-migrate.sh
