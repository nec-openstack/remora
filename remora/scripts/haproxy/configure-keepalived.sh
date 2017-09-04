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
  virtual_router_id ${HAPROXY_KEEPALIVED_VRID:-"1"}
  priority 101
  nopreempt
  advert_int 1
  authentication {
    auth_type PASS
    auth_pass ${HAPROXY_KEEPALIVED_AUTH_PASSWORD:-'himitsu'}
  }
  virtual_ipaddress {
    ${KUBE_PUBLIC_SERVICE_IP}/${HAPROXY_KEEPALIVED_NET_RANGE}   dev ${HAPROXY_KEEPALIVED_NET_DEVICE}
  }
}
EOF
    chmod 664 $TEMPLATE

    local TEMPLATE=/etc/kubernetes/manifests/keepalived.yaml
    echo "TEMPLATE: $TEMPLATE"
    mkdir -p $(dirname $TEMPLATE)
cat << EOF > $TEMPLATE
apiVersion: v1
kind: Pod
metadata:
  name: keepalived
  namespace: kube-system
  labels:
    tier: control-plane
    component: keepalived
spec:
  hostNetwork: true
  containers:
  - name: keepalived
    image: yuanying/keepalived:latest
    securityContext:
      capabilities:
        add: ["NET_ADMIN", "NET_BROADCAST"]
    volumeMounts:
    - mountPath: /etc/keepalived/keepalived.cfg
      name: keepalived
      readOnly: true
  volumes:
  - hostPath:
      path: /etc/keepalived/keepalived.cfg
    name: keepalived
EOF
}

init_templates
