#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`
source ${script_dir}/default-env.sh
source ${script_dir}/utils.sh

host_pattern=${1:-".*"}
target_dir=${2:-"${script_dir}/images"}

CHANNEL=stable
RELEASE=current
IMG_NAME="coreos_${CHANNEL}_${RELEASE}_image.img"
DISCOVERY_URL=$(discovery_url)

if [ ! -d ${target_dir} ]; then
  mkdir -p ${target_dir} || (echo "Can not create ${target_dir} directory" && exit 1)
fi

if [ ! -f $target_dir/$IMG_NAME ]; then
  wget https://${CHANNEL}.release.core-os.net/amd64-usr/${RELEASE}/coreos_production_image.bin.bz2 -O - | bzcat > $target_dir/$IMG_NAME || (rm -f $target_dir/$IMG_NAME && echo "Failed to download image" && exit 1)
fi

bash ${ROOT}/generate-certs.sh

function create_coreos_disk {
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

  local rootfs=${target_dir}/rootfs-${address}
  mkdir -p ${rootfs}

  echo "========================="
  echo "Creating ${host} disk..."

  cp $target_dir/$IMG_NAME $target_dir/coreos-disk-${address}.img

  local loop_device=$(losetup -f)
  local device_basename=$(basename $loop_device)
  losetup ${loop_device} $target_dir/coreos-disk-${address}.img
  kpartx -av ${loop_device}
  # The ROOT partition should be #9 so make assumptions here...
  # If I can, using label is better...
  mount /dev/mapper/${device_basename}p9 ${rootfs}

  echo "---> Copying generated certs..."
  mkdir -p ${rootfs}/etc/kubernetes/ssl
  cp ${LOCAL_CERTS_DIR}/ca.pem ${rootfs}/etc/kubernetes/ssl/ca.pem
  cp ${LOCAL_CERTS_DIR}/ca-key.pem ${rootfs}/etc/kubernetes/ssl/ca-key.pem
  cp ${LOCAL_CERTS_DIR}/apiserver-key-${address}.pem ${rootfs}/etc/kubernetes/ssl/apiserver-key.pem
  cp ${LOCAL_CERTS_DIR}/apiserver-${address}.pem ${rootfs}/etc/kubernetes/ssl/apiserver.pem
  cp ${LOCAL_CERTS_DIR}/worker-key-${address}.pem ${rootfs}/etc/kubernetes/ssl/worker-key.pem
  cp ${LOCAL_CERTS_DIR}/worker-${address}.pem ${rootfs}/etc/kubernetes/ssl/worker.pem

  echo "---> Copying userdata..."
  mkdir -p ${rootfs}/var/lib/coreos-install
  bash ${ROOT}/create-userdata.sh \
    ${host} \
    ${address} \
    ${etcd} > ${rootfs}/var/lib/coreos-install/user_data

  umount ${rootfs}
  kpartx -dv ${loop_device}
  losetup -d ${loop_device}

  echo "Created: $target_dir/coreos-disk-${address}.img"
 }

function create_coreos_disk_lb {
  create_coreos_disk 'lb' ${LB} ${LB_CPU} ${LB_MEMORY} ${LB_DISK}
}

function create_coreos_disk_master {
  local host=$1
  local address=$2
  create_coreos_disk $host $address ${MASTER_CPU} ${MASTER_MEMORY} ${MASTER_DISK} "etcd"
}

function create_coreos_disk_worker {
  local host=$1
  local address=$2
  create_coreos_disk $host $address ${WORKER_CPU} ${WORKER_MEMORY} ${WORKER_DISK}
}

if [[ "lb" =~ ${host_pattern} ]]; then
  create_coreos_disk_lb
fi

i=1
for MASTER_ADDRESS in ${MASTERS}; do
  HOST="master$(printf "%02d" $i)"
  if [[ ${HOST} =~ ${host_pattern} ]]; then
    create_coreos_disk_master ${HOST} ${MASTER_ADDRESS}
  fi
  i=$((i+1))
done

i=1
for WORKER_ADDRESS in ${WORKERS}; do
  HOST="worker$(printf "%02d" $i)"
  if [[ ${HOST} =~ ${host_pattern} ]]; then
    create_coreos_disk_worker ${HOST} ${WORKER_ADDRESS}
  fi
  i=$((i+1))
done
