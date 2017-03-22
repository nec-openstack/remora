#!/usr/bin/env bash

set -eu
export LC_ALL=C

export _NODE_HOSTNAME=${1}
export _NODE_ADDRESS=${2}
# network_range=${3}
# gateway=${4}
# dns=${5}
# net_device=${6}
# discovery_url=${7:-""}
etcd_type=${3:-"worker"}

function cdr2mask {
    # Number of args to shift, 255..255, first non-255 byte, zeroes
    set -- $(( 5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 0 0 0
    [ $1 -gt 1 ] && shift $1 || shift
    echo ${1-0}.${2-0}.${3-0}.${4-0}
}

export NODE_NETMASK=$(cdr2mask ${NODE_NETWORK_RANGE})

if [[ ${NODE_PUBLIC_KEY} == "auto" ]]; then
    export NODE_PUBLIC_KEY=`cat ~/.ssh/id_rsa.pub`
fi

script_dir=`dirname $0`
bash $script_dir/templates/cloud-config-${etcd_type}.yaml
