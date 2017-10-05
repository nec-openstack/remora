#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")

export CLIENT_KEY=${ETCD_CLIENT_KEY}
export CLIENT_CERT_REQ=${ETCD_CLIENT_CERT_REQ}
export CLIENT_CERT=${ETCD_CLIENT_CERT}

bash ${ROOT}/../gen-cert-client.sh etcd "/CN=etcd-client"
