#!/usr/bin/env bash

set -eu
export LC_ALL=C

host=${1}
address=${2}
network_range=${3}
gateway=${4}
dns=${5}
net_device=${6}
discovery_url=${7:-""}
etcd_type=${8:-"worker"}

function cdr2mask {
    # Number of args to shift, 255..255, first non-255 byte, zeroes
    set -- $(( 5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 0 0 0
    [ $1 -gt 1 ] && shift $1 || shift
    echo ${1-0}.${2-0}.${3-0}.${4-0}
}

netmask=$(cdr2mask ${network_range})

public_key=`cat ~/.ssh/id_rsa.pub`

script_dir=`dirname $0`
USER_DATA_TEMPLATE=$script_dir/../templates/cloud-config-${etcd_type}.yaml

sed "
  s|_HOSTNAME_|$host|g
  s|_DNS_|$dns|g
  s|_ADDRESS_|$address|g
  s|_NETWORK_RANGE_|$network_range|g
  s|_NETMASK_|$netmask|g
  s|_GATEWAY_|$gateway|g
  s|_NET_DEVICE_|$net_device|g
  s|_PUBLIC_KEY_|$public_key|g
  s|_DISCOVERY_URL_|$discovery_url|g
" $USER_DATA_TEMPLATE
