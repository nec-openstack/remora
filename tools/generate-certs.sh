#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`
LOCAL_CERTS_DIR=$script_dir/../certs
source ${script_dir}/default-env.sh
source ${script_dir}/utils.sh

export CA_KEY=${CA_KEY:-"${LOCAL_CERTS_DIR}/ca-key.pem"}
export CA_CERT=${CA_CERT:-"${LOCAL_CERTS_DIR}/ca.pem"}

if [[ ! -f ${CA_KEY} ]]; then
  echo "Generate CA key and cert"
  bash ${script_dir}/generate-cert-ca.sh
fi

for MACHINE in ${MACHINES}
do
  echo "Generate Server key and cert for ${MACHINE}"
  bash ${ROOT}/generate-cert-server.sh \
       ${MACHINE}
  echo "Generate Client key and cert for ${MACHINE}"
  bash ${ROOT}/generate-cert-client.sh \
       ${MACHINE}
done
