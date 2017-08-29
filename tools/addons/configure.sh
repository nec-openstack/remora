#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_IP=${1:-${NODE_IP}}

ROOT=$(dirname "${BASH_SOURCE}")
if [ -f "${ROOT}/default-env.sh" ]; then
    source ${ROOT}/default-env.sh
fi

source ${ROOT}/configure-proxy.sh
source ${ROOT}/configure-dns.sh

until curl -skf "https://${KUBE_PUBLIC_SERVICE_IP}:${KUBE_PORT}/healthz"
do
    echo "Waiting for Kubernetes API..."
    sleep 5
done

echo "Install addons..."
for ADDON in ${KUBE_ADDONS}; do
    echo "Addon: ${ADDON}"
    cat /etc/kubernetes/addons/${ADDON}.yaml \
        | ${DOCKER_PATH} run \
            --net=host \
            --rm -i \
            --volume=/etc/kubernetes:/etc/kubernetes:ro \
            ${KUBE_HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION} \
            /hyperkube kubectl --kubeconfig=/etc/kubernetes/admin.yaml apply -f -
done
