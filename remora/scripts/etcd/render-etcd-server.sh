#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBE_IS_MASTER=${KUBE_IS_MASTER:-'0'}
NODE_IP=$1

TEMPLATE=${ETCD_ASSETS_DIR}/etcd-server.yaml
cat << EOF > ${TEMPLATE}
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
    - --name=${ETCD_NODE_NAME}
    - --advertise-client-urls=https://${NODE_IP}:2379
    - --initial-advertise-peer-urls=https://${NODE_IP}:2380
    - --initial-cluster=${ETCD_INITIAL_CLUSTER}
    - --listen-client-urls=https://${NODE_IP}:2379,https://127.0.0.1:2379
    - --listen-peer-urls=https://${NODE_IP}:2380
    - --client-cert-auth=true
    - --cert-file=/etc/etcd/pki/etcd.crt
    - --key-file=/etc/etcd/pki/etcd.key
    - --trusted-ca-file=/etc/etcd/pki/ca.crt
    - --peer-client-cert-auth=true
    - --peer-cert-file=/etc/etcd/pki/etcd.crt
    - --peer-key-file=/etc/etcd/pki/etcd.key
    - --peer-trusted-ca-file=/etc/etcd/pki/ca.crt
    - --data-dir=/var/lib/etcd
    - --heartbeat-interval=${ETCD_HEARTBEAT_INTERVAL}
    - --election-timeout=${ETCD_ELECTION_TIMEOUT}
    volumeMounts:
    - mountPath: /var/lib/etcd
      name: etcd
    - mountPath: /etc/ssl/certs
      name: ssl-certs-host
      readOnly: true
    - mountPath: /usr/share/ca-certificates
      name: ca-certs-host
      readOnly: true
    - mountPath: /etc/etcd/pki
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
      path: /etc/etcd/pki
    name: etcd-certs-host
EOF
