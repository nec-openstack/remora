#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`
source ${script_dir}/default-env.sh
source ${script_dir}/utils.sh

DISCOVERY_URL=$(discovery_url)

function generate_userdata {
    local host=$1
    local address=$2
    local etcd=${3:-""}

    bash ${ROOT}/create-userdata.sh \
      ${host} \
      ${address} \
      ${etcd} > ${ROOT}/userdata/user_data-${address}.yaml
}

generate_userdata 'lb' ${LB}

i=1
for MASTER_ADDRESS in ${MASTERS}; do
    HOST="master$(printf "%02d" $i)"
    generate_userdata ${HOST} ${MASTER_ADDRESS} 'etcd'
    i=$((i+1))
done

i=1
for WORKER_ADDRESS in ${WORKERS}; do
    HOST="worker$(printf "%02d" $i)"
    generate_userdata ${HOST} ${WORKER_ADDRESS}
    i=$((i+1))
done
