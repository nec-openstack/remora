#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_IP=${1:-${NODE_IP}}

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

function init_templates {
    local TEMPLATE=/etc/keepalived/keepalived.cfg
    echo "TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
cat << EOF > $TEMPLATE
vrrp_instance VI {
  state BACKUP
  interface ${HAPROXY_KEEPALIVED_NET_DEVICE}
  garp_master_delay 5
  virtual_router_id 1
  priority 101
  nopreempt
  advert_int 1
  authentication {
    auth_type PASS
    auth_pass himitsu
  }
  virtual_ipaddress {
    ${KUBE_PUBLIC_SERVICE_IP}/${HAPROXY_KEEPALIVED_NET_RANGE}   dev ${HAPROXY_KEEPALIVED_NET_DEVICE}
  }
}
EOF

    local TEMPLATE=/etc/systemd/system/keepalived.service

    echo "TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
cat << EOF > $TEMPLATE
[Unit]
Description=keepalived for cluster services

# Requirements
Requires=docker.service

# Dependency ordering
After=docker.service

[Service]
EnvironmentFile=/etc/environment

ExecStartPre=-${DOCKER_PATH} kill keepalived
ExecStartPre=-${DOCKER_PATH} rm keepalived
ExecStartPre=${DOCKER_PATH} pull yuanying/keepalived:latest

ExecStart=${DOCKER_PATH} run --rm \
  --name keepalived \
  --cap-add=NET_ADMIN \
  --cap-add=NET_BROADCAST \
  --net=host \
  -v /etc/keepalived/keepalived.cfg:/etc/keepalived/keepalived.cfg:ro \
  yuanying/keepalived

[Install]
WantedBy=multi-user.target
EOF
}

init_templates
