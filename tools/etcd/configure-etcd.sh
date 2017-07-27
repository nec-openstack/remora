#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_IP=${1:-${NODE_IP}}
export _HOSTNAME=$(hostname)

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

KUBE_ETCD_TEMPLATE=/etc/kubernetes/manifests/etcd.yaml
mkdir -p $(dirname $KUBE_ETCD_TEMPLATE)
cat << EOF > $KUBE_ETCD_TEMPLATE
apiVersion: v1
kind: Pod
metadata:
  name: etcd
  namespace: kube-system
  labels:
    tier: control-plane
    component: etcd
spec:
  hostNetwork: true
  containers:
  - name: etcd
    image: ${ETCD_IMAGE_REPO}:${ETCD_VERSION}
    command:
    - /usr/local/bin/etcd
    - --name=${_HOSTNAME}
    - --discovery=${ETCD_DISCOVERY_URL}
    - --advertise-client-urls=https://${NODE_IP}:2379
    - --initial-advertise-peer-urls=https://${NODE_IP}:2380
    - --listen-client-urls=https://${NODE_IP}:2379,http://127.0.0.1:2379
    - --listen-peer-urls=https://${NODE_IP}:2380
    - --client-cert-auth=true
    - --cert-file=${ETCD_CERTS_DIR}/etcd.crt
    - --key-file=${ETCD_CERTS_DIR}/etcd.key
    - --trusted-ca-file=${ETCD_CERTS_DIR}/ca.crt
    - --peer-client-cert-auth=true
    - --peer-cert-file=${ETCD_CERTS_DIR}/etcd.crt
    - --peer-key-file=${ETCD_CERTS_DIR}/etcd.key
    - --peer-trusted-ca-file=${ETCD_CERTS_DIR}/ca.crt
    - --data-dir=/var/lib/etcd
    volumeMounts:
    - mountPath: /var/lib/etcd
      name: etcd
    - mountPath: /etc/ssl/certs
      name: ssl-certs-host
      readOnly: true
    - mountPath: /usr/share/ca-certificates
      name: ca-certs-host
      readOnly: true
    - mountPath: ${ETCD_CERTS_DIR}
      name: etcd-certs-host
      readOnly: true
  volumes:
  - hostPath:
      path: /var/lib/etcd
    name: etcd
  - hostPath:
      path: /etc/ssl/certs
    name: ssl-certs-host
  - hostPath:
      path: /usr/share/ca-certificates
    name: ca-certs-host
  - hostPath:
      path: ${ETCD_CERTS_DIR}
    name: etcd-certs-host
EOF
