#!/usr/bin/env bash

set -eu
export LC_ALL=C

DEFAULT_PATTERN="master.*|worker.*"
host_pattern=${1:-${DEFAULT_PATTERN}}

script_dir=`dirname $0`
source ${script_dir}/default-env.sh
source ${script_dir}/utils.sh

function delete_host {
    local host=$1
    local disks=${2:-""}
    echo "Deleting ${host} node..."

    virsh destroy ${host}
    virsh undefine ${host}
    rm -rf ${LIBVIRT_PATH}/${host}*
}

if [[ 'lb' =~ ${host_pattern} ]]; then
    delete_host 'lb' ""
fi

i=1
for HOST in ${MASTERS}; do
    HOST="master$(printf "%02d" $i)"
    if [[ ${HOST} =~ ${host_pattern} ]]; then
        delete_host ${HOST} ""
    fi
    i=$((i+1))
done

i=1
for HOST in ${WORKERS}; do
    HOST="worker$(printf "%02d" $i)"
    if [[ ${HOST} =~ ${host_pattern} ]]; then
        delete_host ${HOST} ${WORKER_ADDISIONAL_DISKS}
    fi
    i=$((i+1))
done
