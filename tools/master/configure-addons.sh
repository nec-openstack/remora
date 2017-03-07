#!/usr/bin/env bash

set -eu
export LC_ALL=C

until curl -sf "http://127.0.0.1:8080/healthz"
do
    echo "Waiting for Kubernetes API..."
    sleep 5
done

KUBE_ADDONS_DIR=/etc/kubernetes/addons

echo "Install essential addons..."

cat ${KUBE_ADDONS_DIR}/kube-proxy.yaml \
    | ${DOCKER_PATH} run --net=host --rm -i ${HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION} /hyperkube kubectl apply -f -

cat ${KUBE_ADDONS_DIR}/kube-dns.yaml \
    | ${DOCKER_PATH} run --net=host --rm -i ${HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION} /hyperkube kubectl apply -f -

cat ${KUBE_ADDONS_DIR}/kube-cni-${KUBE_CNI_PLUGIN}.yaml \
    | ${DOCKER_PATH} run --net=host --rm -i ${HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION} /hyperkube kubectl apply -f -
