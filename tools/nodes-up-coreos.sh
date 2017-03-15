#!/usr/bin/env bash

set -eu
export LC_ALL=C

host_pattern=${1:-".*"}

script_dir=`dirname $0`
source ${script_dir}/default-env.sh
source ${script_dir}/utils.sh

CHANNEL=stable
RELEASE=current
IMG_NAME="coreos_${CHANNEL}_${RELEASE}_qemu_image.img"
DISCOVERY_URL=$(discovery_url)

if [ ! -d $LIBVIRT_PATH ]; then
  mkdir -p $LIBVIRT_PATH || (echo "Can not create $LIBVIRT_PATH directory" && exit 1)
fi

if [ ! -f $LIBVIRT_PATH/$IMG_NAME ]; then
  wget https://${CHANNEL}.release.core-os.net/amd64-usr/${RELEASE}/coreos_production_qemu_image.img.bz2 -O - | bzcat > $LIBVIRT_PATH/$IMG_NAME || (rm -f $LIBVIRT_PATH/$IMG_NAME && echo "Failed to download image" && exit 1)
fi

bash ${ROOT}/generate-certs.sh

function boot_coreos {
  local host=$1
  local address=$2
  local cpus=$3
  local memory=$4
  local disk=$5
  local network_range=${NODE_NETWORK_RANGE}
  local gateway=${NODE_GATEWAY}
  local dns=${NODE_DNS}
  local net_device=${NODE_NET_DEVICE}
  local etcd=${6:-""}

  echo "Creating ${host} node..."

  if [ ! -d $LIBVIRT_PATH/$host/openstack/latest ]; then
    mkdir -p $LIBVIRT_PATH/$host/openstack/latest || (echo "Can not create $LIBVIRT_PATH/$host/openstack/latest directory" && exit 1)
  fi

  if [ ! -f $LIBVIRT_PATH/$host.qcow2 ]; then
    qemu-img create -f qcow2 -b $LIBVIRT_PATH/$IMG_NAME $LIBVIRT_PATH/$host.qcow2
  fi

  ## Copy certs
  MOUNT_POINT=$LIBVIRT_PATH/$host.mount
  mkdir -p ${MOUNT_POINT}
  # enable /dev/nbd before connecting qcow2 image
  # `modprobe nbd max_part=16`
  qemu-nbd --connect=/dev/nbd0 $LIBVIRT_PATH/$host.qcow2
  sleep 1
  mount -o rw /dev/nbd0p9 ${MOUNT_POINT}
  mkdir -p ${MOUNT_POINT}/etc/kubernetes/ssl
  cp ${LOCAL_CERTS_DIR}/ca.pem ${MOUNT_POINT}/etc/kubernetes/ssl/ca.pem
  cp ${LOCAL_CERTS_DIR}/apiserver-key-${address}.pem ${MOUNT_POINT}/etc/kubernetes/ssl/apiserver-key.pem
  cp ${LOCAL_CERTS_DIR}/apiserver-${address}.pem ${MOUNT_POINT}/etc/kubernetes/ssl/apiserver.pem
  cp ${LOCAL_CERTS_DIR}/worker-key-${address}.pem ${MOUNT_POINT}/etc/kubernetes/ssl/worker-key.pem
  cp ${LOCAL_CERTS_DIR}/worker-${address}.pem ${MOUNT_POINT}/etc/kubernetes/ssl/worker.pem
  umount ${MOUNT_POINT}
  qemu-nbd --disconnect /dev/nbd0

  bash ${ROOT}/create-userdata.sh \
    ${host} \
    ${address} \
    ${network_range} \
    ${gateway} \
    ${dns} \
    ${net_device} \
    ${DISCOVERY_URL} \
    ${etcd} > $LIBVIRT_PATH/${host}/openstack/latest/user_data

  virt-install --connect qemu:///system \
               --import \
               --name $host \
               --ram $memory \
               --vcpus $cpus \
               --os-type=linux \
               --os-variant=virtio26 \
               --disk path=$LIBVIRT_PATH/$host.qcow2,format=qcow2,bus=virtio \
               --filesystem $LIBVIRT_PATH/$host/,config-2,type=mount,mode=squash \
               --vnc \
               --noautoconsole
}

function boot_coreos_lb {
  boot_coreos 'lb' ${LB} ${LB_CPU} ${LB_MEMORY} ${LB_DISK}
}

function boot_coreos_master {
  local host=$1
  local address=$2
  boot_coreos $host $address ${MASTER_CPU} ${MASTER_MEMORY} ${MASTER_DISK} "etcd"
}

function boot_coreos_worker {
  local host=$1
  local address=$2
  boot_coreos $host $address ${WORKER_CPU} ${WORKER_MEMORY} ${WORKER_DISK}
}

if [[ "lb" =~ ${host_pattern} ]]; then
  boot_coreos_lb
fi

i=1
for MASTER_ADDRESS in ${MASTERS}; do
  HOST="master$(printf "%02d" $i)"
  if [[ ${HOST} =~ ${host_pattern} ]]; then
    boot_coreos_master ${HOST} ${MASTER_ADDRESS}
  fi
  i=$((i+1))
done

i=1
for WORKER_ADDRESS in ${WORKERS}; do
  HOST="worker$(printf "%02d" $i)"
  if [[ ${HOST} =~ ${host_pattern} ]]; then
    boot_coreos_worker ${HOST} ${WORKER_ADDRESS}
  fi
  i=$((i+1))
done
