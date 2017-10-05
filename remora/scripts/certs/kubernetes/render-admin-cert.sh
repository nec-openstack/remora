#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")

export CLIENT_KEY=${KUBE_ADMIN_KEY}
export CLIENT_CERT_REQ=${KUBE_ADMIN_CERT_REQ}
export CLIENT_CERT=${KUBE_ADMIN_CERT}

bash ${ROOT}/../gen-cert-client.sh admin "/O=system:masters/CN=kubernetes-admin"
