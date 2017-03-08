#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_IP=$1

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
        bind 0.0.0.0:443
        default_backend kube_api_backend
backend kube_api_backend
        option ssl-hello-chk
EOF
    local size=1
    for address in ${MASTERS}; do
        echo "        server api${size} ${address}:443 check" >> ${TEMPLATE}
        size=$((size+1))
    done

    local TEMPLATE=/etc/systemd/system/haproxy.service

    echo "TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
cat << EOF > $TEMPLATE
[Unit]
Description=haproxy for cluster services

# Requirements
Requires=docker.service

# Dependency ordering
After=docker.service

[Service]
EnvironmentFile=/etc/environment

ExecStartPre=-${DOCKER_PATH} kill haproxy
ExecStartPre=-${DOCKER_PATH} rm haproxy
ExecStartPre=${DOCKER_PATH} pull haproxy:alpine

ExecStart=${DOCKER_PATH} run --rm \
  --name haproxy \
  -p 443:443 \
  -v /etc/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro \
  haproxy:alpine

[Install]
WantedBy=multi-user.target
EOF
}

init_templates

systemctl daemon-reload
systemctl enable haproxy
systemctl restart haproxy
