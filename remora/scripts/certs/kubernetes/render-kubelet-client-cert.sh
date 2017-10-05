#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")

export CLIENT_KEY=${KUBE_KUBELET_CLIENT_KEY}
export CLIENT_CERT_REQ=${KUBE_KUBELET_CLIENT_CERT_REQ}
export CLIENT_CERT=${KUBE_KUBELET_CLIENT_CERT}

bash ${ROOT}/../gen-cert-client.sh \
  kubelet-client \
  "/O=system:masters/CN=kube-kubelet-client"
