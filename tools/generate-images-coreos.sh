#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`
source ${script_dir}/default-env.sh
source ${script_dir}/utils.sh

TYPE=${1:-'master'}
TYPE_UP=$(tr '[a-z]' '[A-Z]' <<<${TYPE})
eval "NODES=\$${TYPE_UP}S"
DEFAULT_PATTERN=".*"
address_pattern=${2:-${DEFAULT_PATTERN}}
target_dir=${3:-"${script_dir}/images"}

CHANNEL=stable
RELEASE=current
IMG_NAME="coreos_${CHANNEL}_${RELEASE}_image.img"

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
  local network_range=${NODE_NETWORK_RANGE}
  local gateway=${NODE_GATEWAY}
  local dns=${NODE_DNS}
  local net_device=${NODE_NET_DEVICE}

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

  echo "---> Copying userdata..."
  mkdir -p ${rootfs}/var/lib/coreos-install
  bash ${ROOT}/create-userdata.sh \
    ${host} \
    ${address} \
    coreos > ${rootfs}/var/lib/coreos-install/user_data

  umount ${rootfs}
  sleep 1
  kpartx -dv ${loop_device}
  losetup -d ${loop_device}

  echo "Created: $target_dir/coreos-disk-${address}.img"
 }

i=1
for ADDRESS in ${NODES}; do
  HOST="${TYPE}$(printf "%02d" $i)"
  if [[ ${ADDRESS} =~ ${address_pattern} ]]; then
    create_coreos_disk ${HOST} ${ADDRESS}
  fi
  i=$((i+1))
done
