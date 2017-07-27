#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_IP=${1:-${NODE_IP}}

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

function init_templates {
    local TEMPLATE=/etc/haproxy/haproxy.cfg
    echo "TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
cat << EOF > $TEMPLATE
global
        quiet
        maxconn 2048
defaults
        mode    tcp
        balance leastconn
        timeout client      30000ms
        timeout server      30000ms
        timeout connect      3000ms
        retries 3
frontend kube_api
        bind 0.0.0.0:${KUBE_PORT}
        default_backend kube_api_backend
backend kube_api_backend
        option tcp-check
EOF
    local size=1
    for address in ${HAPROXY_BACKENDS}; do
        echo "        server api${size} ${address}:${KUBE_INTERNAL_PORT} check" >> ${TEMPLATE}
        size=$((size+1))
    done

    local TEMPLATE=/etc/kubernetes/manifests/haproxy.yaml
    echo "TEMPLATE: $TEMPLATE"
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
      path: /etc/haproxy/haproxy.cfg
    name: haproxy
EOF
}

init_templates
