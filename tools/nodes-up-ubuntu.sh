#!/usr/bin/env bash

set -eu
export LC_ALL=C

host_pattern=${1:-".*"}

script_dir=`dirname $0`
source ${script_dir}/default-env.sh
source ${script_dir}/utils.sh

IMG_NAME="ubuntu-xenial.qcow2"

if [ ! -d $LIBVIRT_PATH ]; then
  mkdir -p $LIBVIRT_PATH || (echo "Can not create $LIBVIRT_PATH directory" && exit 1)
fi

if [ ! -f $LIBVIRT_PATH/$IMG_NAME ]; then
    echo "Please set ubuntu image to: $LIBVIRT_PATH/$IMG_NAME" && exit 1
fi

function boot_coreos {
  local host=$1
  local address=$2
  local cpus=$3
  local memory=$4
  local disk=$5
  local disks=${6:-""}
  local network_range=${NODE_NETWORK_RANGE}
  local gateway=${NODE_GATEWAY}
  local dns=${NODE_DNS}
  local net_device=${NODE_NET_DEVICE}

  echo "Creating ${host} node..."

  if [ ! -d $LIBVIRT_PATH/$host/configs ]; then
    mkdir -p $LIBVIRT_PATH/$host/configs || (echo "Can not create $LIBVIRT_PATH/$host/openstack/latest directory" && exit 1)
  fi

  if [ ! -f $LIBVIRT_PATH/$host.qcow2 ]; then
    cp $LIBVIRT_PATH/$IMG_NAME $LIBVIRT_PATH/$host.qcow2
    qemu-img resize $LIBVIRT_PATH/$host.qcow2 ${disk}G
  fi

  local dev_index='b'
  local additional_disk=''
  local additional_disk_params=''
  for disk_size in ${disks}; do
    additional_disk=${LIBVIRT_PATH}/${host}-vd${dev_index}.qcow2
    if [ ! -f ${additional_disk} ]; then
      qemu-img create -f qcow2 ${additional_disk} ${disk_size}
    fi
    additional_disk_params=${additional_disk_params}" --disk path=${additional_disk},format=qcow2,bus=virtio"
    dev_index=$(echo "$dev_index" | tr "0-9a-z" "1-9a-z_")
  done

  bash ${ROOT}/create-userdata.sh \
    ${host} \
    ${address} \
    ubuntu > $LIBVIRT_PATH/${host}/configs/user-data

  uuid=$(uuidgen)
  ssh_key_data=`cat ~/.ssh/id_rsa.pub`
  config_image=$LIBVIRT_PATH/${host}/configs.iso
  cat > $LIBVIRT_PATH/${host}/configs/meta-data <<-EOF
instance-id: $uuid
hostname: $host
local-hostname: $host
public-keys:
  - |
    $ssh_key_data
EOF
  cloud-localds "$config_image" \
    $LIBVIRT_PATH/${host}/configs/user-data \
    $LIBVIRT_PATH/${host}/configs/meta-data

  virt-install --connect qemu:///system \
               --import \
               --name $host \
               --ram $memory \
               --vcpus $cpus \
               --network bridge=br0 \
               --os-type=linux \
               --os-variant=virtio26 \
               --disk path=$LIBVIRT_PATH/$host.qcow2,format=qcow2,bus=virtio \
               ${additional_disk_params} \
               --disk path=${config_image},bus=virtio \
               --vnc \
               --noautoconsole
}

function boot_ubuntu_lb {
  boot_coreos lb ${LB} ${LB_CPU} ${LB_MEMORY} ${LB_DISK} ""
}

function boot_ubuntu_master {
  local host=$1
  local address=$2
  boot_coreos $host $address ${MASTER_CPU} ${MASTER_MEMORY} ${MASTER_DISK} ""
}

function boot_ubuntu_worker {
  local host=$1
  local address=$2
  boot_coreos $host $address ${WORKER_CPU} ${WORKER_MEMORY} ${WORKER_DISK} "${WORKER_ADDISIONAL_DISKS}"
}

if [[ 'lb' =~ ${host_pattern} ]]; then
  boot_ubuntu_lb
fi

i=1
for MASTER_ADDRESS in ${MASTERS}; do
  HOST="master$(printf "%02d" $i)"
  if [[ ${HOST} =~ ${host_pattern} ]]; then
    boot_ubuntu_master ${HOST} ${MASTER_ADDRESS}
  fi
  i=$((i+1))
done

i=1
for WORKER_ADDRESS in ${WORKERS}; do
  HOST="worker$(printf "%02d" $i)"
  if [[ ${HOST} =~ ${host_pattern} ]]; then
    boot_ubuntu_worker ${HOST} ${WORKER_ADDRESS}
  fi
  i=$((i+1))
done
