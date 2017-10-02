#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_IP=${1:-${NODE_IP}}

function init_templates {
    local TEMPLATE=${LOCAL_BOOTSTRAP_ASSETS_DIR}/haproxy.cfg
    mkdir -p $(dirname $TEMPLATE)
cat << EOF > $TEMPLATE
global
        quiet
        maxconn 2048
defaults
        mode    tcp
        balance leastconn
        timeout client      30m
        timeout server      30m
        timeout connect     3000ms
        retries 3
frontend kube_api
        bind 0.0.0.0:${KUBE_PORT}
        default_backend kube_api_backend
backend kube_api_backend
        option tcp-check
        server bootstrap_api ${NODE_IP}:${KUBE_INTERNAL_PORT} check
EOF
    chmod 664 ${TEMPLATE}

    local TEMPLATE=${LOCAL_BOOTSTRAP_ASSETS_DIR}/haproxy.yaml
    mkdir -p $(dirname $TEMPLATE)
cat << EOF > $TEMPLATE
apiVersion: v1
kind: Pod
metadata:
  name: haproxy
  namespace: kube-system
  labels:
    tier: control-plane
    component: haproxy
spec:
  hostNetwork: true
  containers:
  - name: haproxy
    image: haproxy:alpine
    volumeMounts:
    - mountPath: /usr/local/etc/haproxy/haproxy.cfg
      name: haproxy
      readOnly: true
  volumes:
  - hostPath:
      path: /etc/kubernetes/bootstrap/haproxy.cfg
    name: haproxy
EOF
}

init_templates
