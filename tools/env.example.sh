#!/usr/bin/env bash

set -eu
export LC_ALL=C

export USERNAME="ubuntu"

export ETCD_ADDRESS="10.0.0.3"

export MASTER_ADDRESS="10.0.0.4"

export WORKERS_ADDRESS="10.0.0.5 10.0.0.6"


export ETCD_ENDPOINTS=http://${ETCD_ADDRESS}:2379
export K8S_VER=v1.5.3
export HYPERKUBE_IMAGE_REPO=gcr.io/google_containers/hyperkube

export POD_NETWORK=10.2.0.0/16
export SERVICE_IP_RANGE=10.254.0.0/24
export K8S_SERVICE_IP=10.254.0.1
export DNS_SERVER_IP=10.254.0.10
export API_KEY_PATH=/etc/kubernetes/ssl/apiserver-key.pem
