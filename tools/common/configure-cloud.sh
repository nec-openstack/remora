#!/usr/bin/env bash

set -eu
export LC_ALL=C

CLOUD_CONFIG=""

if [[ ${CLOUD_PROVIDER} == "openstack" ]]; then
  CLOUD_CONFIG=/etc/kubernetes/openstack.conf
  mkdir -p $(dirname $CLOUD_CONFIG)
  cat << EOF > $CLOUD_CONFIG
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
EOF
fi

export CLOUD_CONFIG
