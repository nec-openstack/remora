#!/usr/bin/env bash

set -eu
export LC_ALL=C

REMORA_ROOT="/var/remora"
function extract_archive {
    local archive=$1
    cat ${archive} | openssl enc -d -base64 | tar zxvf - -C ${REMORA_ROOT}
}

# Extract certs plugin
CERTS_PLUGIN=${REMORA_ROOT}/certs.plugin.base64
if [ -f "${CERTS_PLUGIN}" ]; then
    extract_archive ${CERTS_PLUGIN}
fi

# Extract network plugin
NETWORK_PLUGIN=${REMORA_ROOT}/network.plugin.base64
if [ -f "${NETWORK_PLUGIN}" ]; then
    extract_archive ${NETWORK_PLUGIN}
fi

# Extract `configure.sh`
REMORA_ARCHIVE=${REMORA_ROOT}/remora.base64
extract_archive ${REMORA_ARCHIVE}


# Run `configure.sh`
bash "${REMORA_ROOT}/configure.sh"
