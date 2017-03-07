#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")

KUBE_ADDONS_DIR=/etc/kubernetes/addons
mkdir -p ${KUBE_ADDONS_DIR}

echo "---" > ${KUBE_ADDONS_DIR}/kube-dns.yaml
cat ${ROOT}/kubedns-sa.yaml >> ${KUBE_ADDONS_DIR}/kube-dns.yaml
echo "---" >> ${KUBE_ADDONS_DIR}/kube-dns.yaml
sed "
  s|__PILLAR__DNS__DOMAIN__|cluster.local|g
  s|__PILLAR__FEDERATIONS__DOMAIN__MAP__||g
  s|__PILLAR__DNS__SERVER__|${KUBE_DNS_SERVER_IP}|g
" ${ROOT}/kubedns-svc.yaml.base >> ${KUBE_ADDONS_DIR}/kube-dns.yaml
echo "---" >> ${KUBE_ADDONS_DIR}/kube-dns.yaml
sed "
  s|__PILLAR__DNS__DOMAIN__|cluster.local|g
  s|__PILLAR__FEDERATIONS__DOMAIN__MAP__||g
  s|__PILLAR__DNS__SERVER__|${KUBE_DNS_SERVER_IP}|g
" ${ROOT}/kubedns-controller.yaml.base >> ${KUBE_ADDONS_DIR}/kube-dns.yaml
