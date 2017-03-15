#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBE_ADDONS_DIR=/etc/kubernetes/addons

ADDONS="kube-proxy kube-dns"

echo "Install addons..."
for ADDON in ${ADDONS}; do
    echo "Addon: ${ADDON}"
    cat ${KUBE_ADDONS_DIR}/${ADDON}.yaml \
        | ${DOCKER_PATH} run \
            --net=host \
            --rm -i \
            ${HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION} \
            /hyperkube kubectl apply -f -
done
