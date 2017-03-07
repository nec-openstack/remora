#!/usr/bin/env bash

set -eu
export LC_ALL=C

until curl -sf "http://127.0.0.1:8080/healthz"
do
    echo "Waiting for Kubernetes API..."
    sleep 5
done

KUBE_ADDONS_DIR=/etc/kubernetes/addons

ADDONS="kube-proxy kube-dns kube-cni-${KUBE_CNI_PLUGIN}"

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
