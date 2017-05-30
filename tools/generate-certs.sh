#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`
source ${script_dir}/default-env.sh
source ${script_dir}/utils.sh

export CA_KEY=${CA_KEY:-"${LOCAL_CERTS_DIR}/ca.key"}
export CA_CERT=${CA_CERT:-"${LOCAL_CERTS_DIR}/ca.crt"}

if [[ ! -f ${CA_KEY} ]]; then
  echo "Generate CA key and cert"
  bash ${script_dir}/gen-cert-ca.sh
fi

echo "Generate Server key and cert"
bash ${ROOT}/generate-cert-server.sh

for MACHINE in ${MACHINES}
do
  echo "Generate Client key and cert for ${MACHINE}"
  bash ${ROOT}/generate-cert-client.sh \
       ${MACHINE}
done
