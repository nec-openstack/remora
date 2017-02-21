#!/usr/bin/env bash

set -eu
export LC_ALL=C

export OPENSTACK_CONF_TEMPLATE=/etc/kubernetes/openstack.conf
mkdir -p $(dirname $OPENSTACK_CONF_TEMPLATE)
cat << EOF > $OPENSTACK_CONF_TEMPLATE
[Global]
auth-url=$OS_AUTH_URL
username=$OS_USERNAME
password=$OS_PASSWORD
region=$OS_REGION_NAME
tenant-name=$OS_TENANT_NAME
domain-id=$OS_USER_DOMAIN_ID
[LoadBalancer]
subnet-id=$SUBNET_ID
floating-network-id=$FLOATING_NETWORK_ID
[Route]
router-id=$ROUTER_ID
EOF
