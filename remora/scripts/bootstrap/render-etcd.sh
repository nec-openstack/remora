#!/usr/bin/env bash

set -eu
export LC_ALL=C

export KUBE_ETCD_TEMPLATE=${KUBE_BOOTSTRAP_MANIFESTS_DIR}/etcd.bootstrap.yaml
mkdir -p $(dirname $KUBE_ETCD_TEMPLATE)
cat << EOF > $KUBE_ETCD_TEMPLATE
---
apiVersion: v1
kind: Pod
metadata:
  name: bootstrap-etcd
  namespace: kube-system
  labels:
    k8s-app: boot-etcd
spec:
  containers:
  - name: etcd
    image: ${ETCD_IMAGE_REPO}:${ETCD_VERSION}
    command:
    - /usr/local/bin/etcd
    - --name=boot-etcd
    - --listen-client-urls=https://0.0.0.0:12379
    - --listen-peer-urls=https://0.0.0.0:12380
    - --advertise-client-urls=https://${ETCD_BOOTSTRAP_CLUSTER_IP}:12379
    - --initial-advertise-peer-urls=https://${ETCD_BOOTSTRAP_CLUSTER_IP}:12380
    - --initial-cluster=boot-etcd=https://${ETCD_BOOTSTRAP_CLUSTER_IP}:12380
    - --initial-cluster-token=bootkube
    - --initial-cluster-state=new
    - --data-dir=/var/etcd/data
    - --peer-client-cert-auth=true
    - --peer-trusted-ca-file=/etc/kubernetes/secrets/etcd/ca.crt
    - --peer-cert-file=/etc/kubernetes/secrets/etcd/etcd.crt
    - --peer-key-file=/etc/kubernetes/secrets/etcd/etcd.key
    - --client-cert-auth=true
    - --trusted-ca-file=/etc/kubernetes/secrets/etcd/ca.crt
    - --cert-file=/etc/kubernetes/secrets/etcd/etcd.crt
    - --key-file=/etc/kubernetes/secrets/etcd/etcd.key
    volumeMounts:
    - mountPath: /etc/kubernetes/secrets
      name: secrets
      readOnly: true
  volumes:
  - name: secrets
    hostPath:
      path: /etc/kubernetes/bootstrap/secrets
  hostNetwork: true
  restartPolicy: Never
  dnsPolicy: ClusterFirstWithHostNet

EOF
