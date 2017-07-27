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
  name: etcd-proxy
  namespace: kube-system
  labels:
    tier: control-plane
    component: etcd-proxy
spec:
  hostNetwork: true
  containers:
  - name: etcd-proxy
    image: ${ETCD_IMAGE_REPO}:${ETCD_VERSION}
    command:
    - /usr/local/bin/etcd
    - --name=${_HOSTNAME}
    - --proxy=on
    - --discovery=${ETCD_DISCOVERY_URL}
    - --listen-client-urls=http://127.0.0.1:2379
    - --cert-file=${ETCD_CERTS_DIR}/etcd-client.crt
    - --key-file=${ETCD_CERTS_DIR}/etcd-client.key
    - --trusted-ca-file=${ETCD_CERTS_DIR}/ca.crt
    - --peer-cert-file=${ETCD_CERTS_DIR}/etcd-client.crt
    - --peer-key-file=${ETCD_CERTS_DIR}/etcd-client.key
    - --peer-trusted-ca-file=${ETCD_CERTS_DIR}/ca.crt
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
