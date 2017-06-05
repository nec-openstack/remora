#!/usr/bin/env bash

set -eu
export LC_ALL=C

# export NODE_IP=$1

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
    image: ${KUBE_HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION}
    command:
    - /hyperkube
    - scheduler
    - --master=http://127.0.0.1:8080
    - --leader-elect=true
    - --v=${KUBE_LOG_LEVEL:-"2"}
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
