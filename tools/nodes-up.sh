#!/usr/bin/env bash

set -eu
export LC_ALL=C

OS_DISTRO=${1:-'coreos'}
TYPE=${2:-'master'}
DEFAULT_PATTERN=".*"
address_pattern=${3:-${DEFAULT_PATTERN}}

script_dir=`dirname $0`
source ${script_dir}/default-env.sh
source ${script_dir}/utils.sh

TYPE_UP=$(tr '[a-z]' '[A-Z]' <<<${TYPE})

eval "NODES=\$${TYPE_UP}S"

i=1
for ADDRESS in ${NODES}; do
    HOST="${TYPE}$(printf "%02d" $i)"
    if [[ ${ADDRESS} =~ ${address_pattern} ]]; then
        bash ${script_dir}/node-up.sh \
            ${OS_DISTRO} \
            ${TYPE} \
            ${HOST} \
            ${ADDRESS}
    fi
    i=$((i+1))
done
