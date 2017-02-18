#!/usr/bin/env bash

set -eu
export LC_ALL=C

# export NODE_IP=$1
# export ETCD_ADDRESS=$2
#
# export ETCD_ENDPOINTS=http://${ETCD_ADDRESS}:2379
# export K8S_VER=v1.5.3
# export HYPERKUBE_IMAGE_REPO=gcr.io/google_containers/hyperkube
#
# export POD_NETWORK=10.2.0.0/16
# export SERVICE_IP_RANGE=10.254.0.0/24
# export K8S_SERVICE_IP=10.254.0.1
# export DNS_SERVER_IP=10.254.0.10

SCHE_TEMPLATE=/etc/kubernetes/manifests/kube-scheduler.yaml
mkdir -p $(dirname $SCHE_TEMPLATE)
cat << EOF > $SCHE_TEMPLATE
apiVersion: v1
kind: Pod
metadata:
  name: kube-scheduler
  namespace: kube-system
  labels:
    tier: control-plane
    component: kube-scheduler
spec:
  hostNetwork: true
  containers:
  - name: kube-scheduler
    image: ${HYPERKUBE_IMAGE_REPO}:${K8S_VER}
    command:
    - /hyperkube
    - scheduler
    - --master=http://127.0.0.1:8080
    - --leader-elect=true
    resources:
      requests:
        cpu: 100m
    livenessProbe:
      httpGet:
        host: 127.0.0.1
        path: /healthz
        port: 10251
      initialDelaySeconds: 15
      timeoutSeconds: 15
EOF
