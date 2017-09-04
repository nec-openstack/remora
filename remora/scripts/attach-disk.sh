#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh
source ${ROOT}/utils.sh

VM_NAME=${1}
VOL_SIZE=${2:-"12"}
VOL_DEVICE=${3:-"vdb"}

VOL_FILE=${LIBVIRT_PATH}/${VM_NAME}-${VOL_DEVICE}.img
if [ -f ${VOL_FILE} ]; then
   echo "${VOL_FILE} : already exists"
   exit 1
fi
qemu-img create ${VOL_FILE} ${VOL_SIZE}G

virsh attach-device ${VM_NAME} <(cat <<EOF
<disk type='file' device='disk'>
   <driver name='qemu' type='qcow2' cache='none'/>
   <source file='${VOL_FILE}'/>
   <target dev='${VOL_DEVICE}' bus='virtio'/>
</disk>
EOF
)

virsh attach-device ${VM_NAME} --config <(cat <<EOF
<disk type='file' device='disk'>
   <driver name='qemu' type='qcow2' cache='none'/>
   <source file='${VOL_FILE}'/>
   <target dev='${VOL_DEVICE}' bus='virtio'/>
</disk>
EOF
)
