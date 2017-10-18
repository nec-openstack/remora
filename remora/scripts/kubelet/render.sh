#!/usr/bin/env bash

set -eu
export LC_ALL=C

export NODE_IP=${1:-${NODE_IP}}

ROOT=$(dirname "${BASH_SOURCE}")
KUBELET_HOSTNAME=${NODE_IP}

mkdir -p ${KUBELET_ASSETS_DIR}

if [[ ${KUBE_CLOUD_PROVIDER} == "openstack" ]]; then
  if which openstack ; then
    export OS_REGION_NAME=${OPENSTACK_REGION_NAME:-"RegionOne"}
    export OS_IDENTITY_API_VERSION=${OPENSTACK_IDENTITY_API_VERSION:-"3"}
    export OS_PASSWORD=${OPENSTACK_PASSWORD:-""}
    export OS_USER_DOMAIN_NAME=${OPENSTACK_USER_DOMAIN_NAME:-""}
    export OS_USER_DOMAIN_ID=${OPENSTACK_USER_DOMAIN_ID:-""}
    export OS_PROJECT_DOMAIN_NAME=${OPENSTACK_PROJECT_DOMAIN_NAME:-""}
    export OS_PROJECT_DOMAIN_ID=${OPENSTACK_PROJECT_DOMAIN_ID:-""}
    export OS_AUTH_URL=${OPENSTACK_AUTH_URL}
    export OS_USERNAME=${OPENSTACK_USERNAME}
    OPENSTACK_PROJECT_NAME=${OPENSTACK_PROJECT_NAME:-${OPENSTACK_TENANT_NAME}}
    export OS_PROJECT_NAME=${OPENSTACK_PROJECT_NAME}

    if [[ ${OPENSTACK_USER_DOMAIN_NAME:-""} ]]; then
      DOMAIN_USER_DOMAIN_ID=$(openstack domain show ${OPENSTACK_USER_DOMAIN_NAME} -f value -c id)
    fi
    if [[ ${OPENSTACK_SUBNET_NAME:-""} ]]; then
      OPENSTACK_SUBNET_ID=$(openstack subnet show ${OPENSTACK_SUBNET_NAME} -f value -c id)
    fi
    if [[ ${OPENSTACK_FLOATING_NETWORK_NAME:-""} ]]; then
      OPENSTACK_FLOATING_NETWORK_ID=$(openstack network show ${OPENSTACK_FLOATING_NETWORK_NAME} -f value -c id)
    fi
    if [[ ${OPENSTACK_ROUTER_NAME:-""} ]]; then
      OPENSTACK_ROUTER_ID=$(openstack router show ${OPENSTACK_ROUTER_NAME} -f value -c id)
    fi
    KUBELET_HOSTNAME=$(openstack server list -f value -c Name -c Networks | awk "/=${NODE_IP}$/{print \$1}")
  else
    echo "\`openstack\` command is needed to render 'OpenStack Cloud Provider'"
    exit 1
  fi
fi

source ${ROOT}/render-cert-kubelet.sh "/O=system:nodes/CN=system:node:${KUBELET_HOSTNAME}"
source ${ROOT}/render-cloud.sh
source ${ROOT}/render-kubeconfig.sh
source ${ROOT}/render-kubelet.sh
source ${ROOT}/render-installer.sh
