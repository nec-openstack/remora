#!/usr/bin/env bash

export OS_AUTH_URL=${OS_AUTH_URL:-"http://192.168.11.197:5000/v3/"}
export OS_USERNAME=${OS_USERNAME:-"demo"}
export OS_PASSWORD=${OS_PASSWORD:-"openstack"}
export OS_REGION_NAME=${OS_REGION_NAME:-"RegionOne"}
export OS_TENANT_NAME=${OS_TENANT_NAME:-"demo"}
export OS_USER_DOMAIN_ID=${OS_USER_DOMAIN_ID:-"default"}
export SUBNET_ID=${SUBNET_ID:-"d5eb5d67-1ff1-4f7a-9718-7233f30b9032"}
export FLOATING_NETWORK_ID=${FLOATING_NETWORK_ID:-"affd1fff-193b-45c2-ab18-276a8435bd8c"}
export ROUTER_ID=${ROUTER_ID:-"7f43c6e5-a344-4b47-8e63-eb70b414a48b"}

set -eu
export LC_ALL=C

export USERNAME="ubuntu"

export ETCD_ADDRESS="10.0.0.3"

export MASTER_ADDRESS="10.0.0.4"

export WORKERS_ADDRESS="10.0.0.5 10.0.0.6"


export ETCD_ENDPOINTS=http://${ETCD_ADDRESS}:2379
export K8S_VER=v1.6.0-alpha.3
export HYPERKUBE_IMAGE_REPO=gcr.io/google_containers/hyperkube

export POD_NETWORK=10.2.0.0/16
export SERVICE_IP_RANGE=10.254.0.0/24
export K8S_SERVICE_IP=10.254.0.1
export DNS_SERVER_IP=10.254.0.10
export API_KEY_PATH=/etc/kubernetes/ssl/apiserver-key.pem
