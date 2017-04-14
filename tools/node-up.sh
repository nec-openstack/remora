#!/usr/bin/env bash

set -eu
export LC_ALL=C

OS_DISTRO=${1:-'coreos'}
TYPE=${2:-'master'}
HOST=${3:-$(uuidgen)}
ADDRESS=${4:-'192.168.1.101'}

TYPE_UP=$(tr '[a-z]' '[A-Z]' <<<${TYPE})

script_dir=`dirname $0`
source ${script_dir}/default-env.sh
source ${script_dir}/utils.sh

eval "CPUS=\$${TYPE_UP}_CPU"
eval "MEMORY=\$${TYPE_UP}_MEMORY"
eval "DISK=\$${TYPE_UP}_DISK"
eval "DISKS=\$\{${TYPE_UP}_ADDISIONAL_DISKS:-''\}"

NODE_NETWORK_RANGE=${NODE_NETWORK_RANGE:-'16'}
NODE_GATEWAY=${NODE_GATEWAY:-'192.168.11.1'}
NODE_DNS=${NODE_DNS:-'8.8.8.8'}
NODE_NET_DEVICE=${NODE_NET_DEVICE:-'eth0'}

if [ ! -d $LIBVIRT_PATH ]; then
    mkdir -p $LIBVIRT_PATH || (echo "Can not create $LIBVIRT_PATH directory" && exit 1)
fi

if [[ ${OS_DISTRO} == 'coreos' ]]; then
    # setup IMAGE
    CHANNEL=stable
    RELEASE=current
    IMG_NAME="coreos_${CHANNEL}_${RELEASE}_qemu_image.img"
    if [ ! -f $LIBVIRT_PATH/$IMG_NAME ]; then
        wget https://${CHANNEL}.release.core-os.net/amd64-usr/${RELEASE}/coreos_production_qemu_image.img.bz2 -O - | bzcat > $LIBVIRT_PATH/$IMG_NAME || (rm -f $LIBVIRT_PATH/$IMG_NAME && echo "Failed to download image" && exit 1)
    fi

    USERDATA_PATH=$LIBVIRT_PATH/${HOST}/openstack/latest
elif [[ ${OS_DISTRO} == 'ubuntu' ]]; then
    # setup IMAGE
    IMG_NAME="ubuntu-xenial.qcow2"
    if [ ! -f $LIBVIRT_PATH/$IMG_NAME ]; then
        echo "Please set ubuntu image to: $LIBVIRT_PATH/$IMG_NAME" && exit 1
    fi

    USERDATA_PATH=$LIBVIRT_PATH/${HOST}/configs
fi

echo "Setup USERDATA: ${HOST} node..."

if [ ! -d $USERDATA_PATH ]; then
    mkdir -p $USERDATA_PATH || (echo "Can not create $USERDATA_PATH directory" && exit 1)
fi

if [[ ${OS_DISTRO} == 'coreos' ]]; then
    # setup USERDATA
    bash ${ROOT}/create-userdata.sh \
        ${HOST} \
        ${ADDRESS} \
        ${OS_DISTRO} > ${USERDATA_PATH}/user-data
    USERDATA_DISK="--filesystem $LIBVIRT_PATH/$HOST/,config-2,type=mount,mode=squash"
elif [[ ${OS_DISTRO} == 'ubuntu' ]]; then
    # setup USERDATA
    bash ${ROOT}/create-userdata.sh \
        ${HOST} \
        ${ADDRESS} \
        ${OS_DISTRO} > ${USERDATA_PATH}/user-data
        uuid=$(uuidgen)
        ssh_key_data=`cat ~/.ssh/id_rsa.pub`
        config_image=$LIBVIRT_PATH/${HOST}/configs.iso
    cat > $LIBVIRT_PATH/${HOST}/configs/meta-data <<-EOF
instance-id: $uuid
hostname: ${HOST}
local-hostname: ${HOST}
public-keys:
  - |
    $ssh_key_data
EOF
    cloud-localds "$config_image" \
        $LIBVIRT_PATH/${HOST}/configs/user-data \
        $LIBVIRT_PATH/${HOST}/configs/meta-data
    USERDATA_DISK="--disk path=${config_image},bus=virtio"
fi

echo "Creating: ${HOST} node..."

if [ ! -f $LIBVIRT_PATH/${HOST}.qcow2 ]; then
    cp $LIBVIRT_PATH/$IMG_NAME $LIBVIRT_PATH/${HOST}-${OS_DISTRO}.qcow2
    qemu-img resize $LIBVIRT_PATH/${HOST}-${OS_DISTRO}.qcow2 ${DISK}G
fi

local dev_index='b'
local additional_disk=''
local additional_disk_params=''
for disk_size in ${DISKS}; do
    additional_disk=${LIBVIRT_PATH}/${HOST}-vd${dev_index}.img
    if [ ! -f ${additional_disk} ]; then
        qemu-img create ${additional_disk} ${disk_size}G
    fi
    additional_disk_params=${additional_disk_params}" --disk path=${additional_disk},format=raw,bus=virtio"
    dev_index=$(echo "$dev_index" | tr "0-9a-z" "1-9a-z_")
done

virt-install --connect qemu:///system \
             --import \
             --name $HOST \
             --ram $MEMORY \
             --vcpus $CPUS \
             --network bridge=br0 \
             --os-type=linux \
             --os-variant=virtio26 \
             --disk path=$LIBVIRT_PATH/${HOST}-${OS_DISTRO}.qcow2,format=qcow2,bus=virtio \
             ${additional_disk_params} \
             ${USERDATA_DISK} \
             --vnc \
             --noautoconsole
