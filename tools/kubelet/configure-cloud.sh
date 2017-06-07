#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBE_CLOUD_CONFIG=""

if [[ ${KUBE_CLOUD_PROVIDER} == "openstack" ]]; then
  KUBE_CLOUD_CONFIG=/etc/kubernetes/openstack.conf
  mkdir -p $(dirname $KUBE_CLOUD_CONFIG)
  cat << EOF > $KUBE_CLOUD_CONFIG
[Global]
auth-url=$OS_AUTH_URL
username=$OS_USERNAME
password=$OS_PASSWORD
region=$OS_REGION_NAME
tenant-name=$OS_TENANT_NAME
domain-id=$OS_USER_DOMAIN_ID
[LoadBalancer]
subnet-id=$OS_SUBNET_ID
floating-network-id=$OS_FLOATING_NETWORK_ID
[Route]
router-id=$OS_ROUTER_ID
EOF
fi

export KUBE_CLOUD_CONFIG
