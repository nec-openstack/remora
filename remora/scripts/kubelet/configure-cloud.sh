#!/usr/bin/env bash

set -eu
export LC_ALL=C

if [[ ${KUBE_CLOUD_PROVIDER} == "openstack" ]]; then
  mkdir -p $(dirname $KUBE_CLOUD_CONFIG)
  cat << EOF > $KUBE_CLOUD_CONFIG
[Global]
auth-url=$OPENSTACK_AUTH_URL
username=$OPENSTACK_USERNAME
password=$OPENSTACK_PASSWORD
region=$OPENSTACK_REGION_NAME
tenant-name=$OPENSTACK_TENANT_NAME
domain-id=$OPENSTACK_USER_DOMAIN_ID
[LoadBalancer]
subnet-id=${OPENSTACK_SUBNET_ID:-""}
floating-network-id=${OPENSTACK_FLOATING_NETWORK_ID:-""}
[Route]
router-id=${OPENSTACK_ROUTER_ID:-""}
EOF
fi

export KUBE_CLOUD_CONFIG
