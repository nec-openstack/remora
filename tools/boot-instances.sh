#!/usr/bin/env bash

set -eu
export LC_ALL=C

function create_flavors {
    if ! openstack --os-region-name="$OS_REGION_NAME" flavor list | grep -q k2.master; then
        openstack --os-region-name="$OS_REGION_NAME" flavor create --id k2m --ram 2048 --disk 40 --vcpus 1 k2.master
        openstack --os-region-name="$OS_REGION_NAME" flavor create --id k2w --ram 2048 --disk 40 --vcpus 1 k2.worker
    fi
}

function boot_servers {
    if ! nova list | grep -q etcd; then
        nova boot --key-name default \
            --image ubuntu-docker \
            --flavor=k2.master \
            --nic net-name=private,v4-fixed-ip="10.0.0.6" \
            etcd
    fi

    if ! nova list | grep -q master; then
        nova boot --key-name default \
            --image ubuntu-docker \
            --flavor=k2.master \
            --nic net-name=private,v4-fixed-ip="10.0.0.3" \
            master
    fi

    if ! nova list | grep -q worker01; then
        nova boot --key-name default \
            --image ubuntu-docker \
            --flavor=k2.worker \
            --nic net-name=private,v4-fixed-ip="10.0.0.5" \
            worker01
    fi

    if ! nova list | grep -q worker02; then
        nova boot --key-name default \
            --image ubuntu-docker \
            --flavor=k2.worker \
            --nic net-name=private,v4-fixed-ip="10.0.0.15" \
            worker02
    fi
}

function configure_security_group {
  if ! neutron security-group-rule-list | grep -q "1-65535/tcp"; then
    neutron security-group-rule-create \
      --direction ingress \
      --protocol icmp \
      default
    neutron security-group-rule-create \
      --direction ingress \
      --protocol tcp \
      --port_range_min 1 \
      --port_range_max 65535 \
      default
    fi
}

create_flavors
configure_security_group
boot_servers
