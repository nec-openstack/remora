#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`
source ${script_dir}/default-env.sh
source ${script_dir}/utils.sh

SA_KEY=${SA_KEY:-"${LOCAL_CERTS_DIR}/sa.key"}
SA_PUB=${SA_PUB:-"${LOCAL_CERTS_DIR}/sa.pub"}

if [[ ! -f ${SA_KEY} ]]; then
    openssl genrsa -out "${SA_KEY}" 4096
    openssl rsa -pubout -in "${SA_KEY}" -out "${SA_PUB}"
fi
