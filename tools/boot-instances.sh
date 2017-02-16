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
            --nic net-name=private \
            etcd
    fi

    if ! nova list | grep -q master; then
        nova boot --key-name default \
            --image ubuntu-docker \
            --flavor=k2.master \
            --nic net-name=private \
            master
    fi

    if ! nova list | grep -q worker01; then
        nova boot --key-name default \
            --image ubuntu-docker \
            --flavor=k2.worker \
            --nic net-name=private \
            worker01
    fi

    if ! nova list | grep -q worker02; then
        nova boot --key-name default \
            --image ubuntu-docker \
            --flavor=k2.worker \
            --nic net-name=private \
            worker02
    fi
}

create_flavors
boot_servers
