#!/usr/bin/env bash

set -eu
export LC_ALL=C

if [[ ${KUBE_CLOUD_PROVIDER} == "openstack" ]]; then
  cat << EOF > ${KUBELET_ASSETS_DIR}/cloud.ini
[Global]
auth-url=$OPENSTACK_AUTH_URL
username=$OPENSTACK_USERNAME
password=$OPENSTACK_PASSWORD
region=$OPENSTACK_REGION_NAME
tenant-name=$OPENSTACK_PROJECT_NAME
domain-id=$OPENSTACK_USER_DOMAIN_ID
[LoadBalancer]
subnet-id=${OPENSTACK_SUBNET_ID:-""}
floating-network-id=${OPENSTACK_FLOATING_NETWORK_ID:-""}
[Route]
router-id=${OPENSTACK_ROUTER_ID:-""}
EOF
fi
