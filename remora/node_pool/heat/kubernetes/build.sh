#!/usr/bin/env bash

set -eu
export LC_ALL=C

# Required parameters
export ETCD_ENDPOINT=${ETCD_ENDPOINT:-""}
export OS_AUTH_URL=${OS_AUTH_URL:-"http://192.168.11.197:5000/v3/"}
export OS_USERNAME=${OS_USERNAME:-"demo"}
export OS_PASSWORD=${OS_PASSWORD:-"openstack"}
export OS_REGION_NAME=${OS_REGION_NAME:-"RegionOne"}
export OS_TENANT_NAME=${OS_TENANT_NAME:-"demo"}
export OS_USER_DOMAIN_ID=${OS_USER_DOMAIN_ID:-"default"}
export OS_SUBNET_ID=${OS_SUBNET_ID:-"private-subnet"}
export OS_FLOATING_NETWORK_ID=${OS_FLOATING_NETWORK_ID:-"public"}

# Option
export DOCKER_PATH=${DOCKER_PATH:-"/usr/bin/docker"}

export HYPERKUBE_IMAGE_REPO=${HYPERKUBE_IMAGE_REPO:-"gcr.io/google_containers/hyperkube"}
export KUBE_VERSION=${KUBE_VERSION:-"v1.5.3"}
export KUBE_CLUSTER_CIDR=${KUBE_CLUSTER_CIDR:-"10.244.0.0/16"}
export KUBE_SERVICE_IP_RANGE=${KUBE_SERVICE_IP_RANGE:-"10.254.0.0/24"}
export KUBE_INTERNAL_SERVICE_IP=${KUBE_INTERNAL_SERVICE_IP:-"10.254.0.1"}
export KUBE_DNS_SERVER_IP=${KUBE_DNS_SERVER_IP:-"10.254.0.10"}
export KUBE_CNI_PLUGIN=${KUBE_CNI_PLUGIN:-"flannel"}
export KUBE_PORT=${KUBE_PORT:-"443"}
export KUBE_ADMISSION_CONTROL=${KUBE_ADMISSION_CONTROL:-"NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,ResourceQuota"}

export FLANNEL_VER=${FLANNEL_VER:-"v0.7.0"}
export FLANNEL_IMAGE_REPO=${FLANNEL_IMAGE_REPO:-"quay.io/coreos/flannel"}
export FLANNEL_BACKEND_TYPE=${FLANNEL_BACKEND_TYPE:-"vxlan"}

export CLOUD_PROVIDER=${CLOUD_PROVIDER:-""}

function compress_directory {
    local target_dir=$1
    local archive_path=$2
    cd ${target_dir}
    tar zcvf - . | openssl enc -e -base64 > ${archive_path}
    popd
}

function wait_lb {
    local target_lb=$1
    provisioning_status=""
    until [[ ${provisioning_status} == 'ACTIVE' ]]; do
        provisioning_status="$(neutron lbaas-loadbalancer-show -c provisioning_status ${target_lb} -f value)"
        echo "Waiting loadbalancer become ACTIVE: current ${provisioning_status}"
        sleep 5
    done
}

WORKING_DIR=$(mktemp -d /tmp/remora.XXXXXX)
cd ${WORKING_DIR}

neutron lbaas-loadbalancer-create --name remora-lb ${OS_SUBNET_ID}

wait_lb remora-lb

neutron lbaas-listener-create \
    --loadbalancer remora-lb \
    --name remora-lb-k8s-listener \
    --protocol TCP \
    --protocol-port ${KUBE_PORT}

wait_lb remora-lb

neutron lbaas-pool-create \
    --lb-algorithm LEAST_CONNECTIONS \
    --listener remora-lb-k8s-listener \
    --protocol TCP \
    --name remora-lb-k8s-pool

wait_lb remora-lb

neutron lbaas-healthmonitor-create \
    --delay 5 \
    --max-retries 2 \
    --timeout 10 \
    --type TCP \
    --pool remora-lb-k8s-pool
popd
