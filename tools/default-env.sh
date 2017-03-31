#!/usr/bin/env bash

set -eu
export LC_ALL=C

CLUSTER_NAME=${CLUSTER_NAME:-""}

if [[ ${CLUSTER_NAME} == "" ]]; then
    echo "CLUSTER_NAME isn't specified"
    read -p "Do you want to procede? (y/n)? " answer
    if echo "$answer" | grep -iq "^y" ;then
        export CLUSTER_NAME="anonymous"
    else
        exit
    fi
fi

echo "Starting configuration: ${CLUSTER_NAME}"

ROOT=$(dirname "${BASH_SOURCE}")
if [ -f "${ROOT}/env.sh" ]; then
    source "${ROOT}/env.sh"
fi
if [ -f "${ROOT}/env.${CLUSTER_NAME}.sh" ]; then
    source "${ROOT}/env.${CLUSTER_NAME}.sh"
fi

export KUBERNETES_SERVICE_IP=${KUBERNETES_SERVICE_IP:-"192.168.1.101"}
export LB=${LB:-"192.168.1.101"}
export MASTERS=${MASTERS:-"192.168.1.111 192.168.1.112 192.168.1.113"}
export ETCDS=${ETCDS:-${MASTERS}}
export WORKERS=${WORKERS:-"192.168.1.121 192.168.1.122"}
export ETCD_PROXIES=${ETCD_PROXIES:-${WORKERS}}

## For certs

export LOCAL_CERTS_DIR=${ROOT}/certs

## For Docker

export DOCKER_PATH=${DOCKER_PATH:-"/usr/bin/docker"}

## For Etcd

export ETCD_ENDPOINT=${ETCD_ENDPOINT:-http://127.0.0.1:2379}
export ETCD_V3_VERSION_TAG=${ETCD_V3_VERSION_TAG:-"v3.1.5"}
export ETCD_IMAGE_REPO=${ETCD_IMAGE_REPO:-"quay.io/coreos/etcd"}
export ETCD_CERTS_DIR=${ETCD_CERTS_DIR:-"/etc/kubernetes/ssl"}

## For Flannel

export FLANNEL_VER=${FLANNEL_VER:-"v0.7.0"}
export FLANNEL_IMAGE_REPO=${FLANNEL_IMAGE_REPO:-"quay.io/coreos/flannel"}
export FLANNEL_BACKEND_TYPE=${FLANNEL_BACKEND_TYPE:-"vxlan"}

## For Kubernetes Setup

export HYPERKUBE_IMAGE_REPO=${HYPERKUBE_IMAGE_REPO:-"gcr.io/google_containers/hyperkube"}
export KUBE_VERSION=${KUBE_VERSION:-"v1.6.0"}
export KUBE_CLUSTER_CIDR=${KUBE_CLUSTER_CIDR:-"10.244.0.0/16"}
export KUBE_SERVICE_IP_RANGE=${KUBE_SERVICE_IP_RANGE:-"10.254.0.0/24"}
export KUBE_INTERNAL_SERVICE_IP=${KUBE_INTERNAL_SERVICE_IP:-"10.254.0.1"}
export KUBE_ADDITIONAL_HOSTNAMES=""
export KUBE_ADDITIONAL_SERVICE_IPS=""
export KUBE_DNS_SERVER_IP=${KUBE_DNS_SERVER_IP:-"10.254.0.10"}
export KUBE_CNI_PLUGIN=${KUBE_CNI_PLUGIN:-"flannel"}
export KUBE_PORT=${KUBE_PORT:-"443"}
export KUBE_INTERNAL_PORT=${KUBE_INTERNAL_PORT:-"6443"}
export KUBE_ADMISSION_CONTROL=${KUBE_ADMISSION_CONTROL:-"NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,ResourceQuota"}
export KUBE_STORAGE_BACKEND=${KUBE_STORAGE_BACKEND:-"etcd3"}
export KUBE_TEMP="~/kube_temp"

## For cloud provider

export CLOUD_PROVIDER=${CLOUD_PROVIDER:-""}
export OS_AUTH_URL=${OS_AUTH_URL:-"http://192.168.11.197:5000/v3/"}
export OS_USERNAME=${OS_USERNAME:-"demo"}
export OS_PASSWORD=${OS_PASSWORD:-"openstack"}
export OS_REGION_NAME=${OS_REGION_NAME:-"RegionOne"}
export OS_TENANT_NAME=${OS_TENANT_NAME:-"demo"}
export OS_USER_DOMAIN_ID=${OS_USER_DOMAIN_ID:-"default"}
export OS_SUBNET_ID=${OS_SUBNET_ID:-"d5eb5d67-1ff1-4f7a-9718-7233f30b9032"}
export OS_FLOATING_NETWORK_ID=${OS_FLOATING_NETWORK_ID:-"affd1fff-193b-45c2-ab18-276a8435bd8c"}
export OS_ROUTER_ID=${OS_ROUTER_ID:-"7f43c6e5-a344-4b47-8e63-eb70b414a48b"}

## For Node bootstrap

export LIBVIRT_PATH=/var/lib/libvirt/images/coreos

export NODE_USERNAME=${NODE_USERNAME:-"ubuntu"}
export NODE_NETWORK_RANGE=${NODE_NETWORK_RANGE:-16}
export NODE_GATEWAY=${NODE_GATEWAY:-192.168.11.1}
export NODE_DNS=${NODE_DNS:-8.8.8.8}
export NODE_NET_DEVICE=${NODE_NET_DEVICE:-"eth0"}
export NODE_PUBLIC_KEY=${NODE_PUBLIC_KEY:-"auto"}

export LB_MEMORY=${MASTER_MEMORY:-2048}
export LB_CPU=${MASTER_CPU:-1}
export LB_DISK=${MASTER_DISK:-20}

export MASTER_MEMORY=${MASTER_MEMORY:-"2048"}
export MASTER_CPU=${MASTER_CPU:-"1"}
export MASTER_DISK=${MASTER_DISK:-"20"}

export WORKER_MEMORY=${WORKER_MEMORY:-"2048"}
export WORKER_CPU=${WORKER_CPU:-"1"}
export WORKER_DISK=${WORKER_DISK:-"20"}
export WORKER_ADDISIONAL_DISKS=${WORKER_ADDISIONAL_DISKS:-"40"}

## For coreos

export DISCOVERY_URL=${DISCOVERY_URL:-""}

## For instance use

MACHINES="${MASTERS} ${WORKERS}"
export MACHINES=$(echo "${MACHINES[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
