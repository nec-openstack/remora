#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`
source ${script_dir}/default-env.sh
source ${script_dir}/utils.sh

OS_DISTRO=${1:-'coreos'}
TYPE=${2:-'master'}
TYPE_UP=$(tr '[a-z]' '[A-Z]' <<<${TYPE})
eval "NODES=\$${TYPE_UP}S"

function generate_userdata {
    local host=$1
    local address=$2

    bash ${ROOT}/create-userdata.sh \
      ${host} \
      ${address} \
      ${OS_DISTRO} > ${ROOT}/userdata/user_data-${address}.yaml
}

i=1
for ADDRESS in ${NODES}; do
    HOST="${TYPE}$(printf "%02d" $i)"
    generate_userdata ${HOST} ${ADDRESS}
    i=$((i+1))
done
