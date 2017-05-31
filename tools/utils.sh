#!/usr/bin/env bash

set -eu
export LC_ALL=C

SSH_OPTS="-oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -oLogLevel=ERROR"

# Run command over ssh
function kube-ssh() {
  local host="$1"
  shift
  ssh ${SSH_OPTS} -t "${host}" "$@" >/dev/null
}

function kube-scp() {
  local host="$1"
  local src=($2)
  local dst="$3"
  scp -r ${SSH_OPTS} ${src[*]} "${host}:${dst}"
}

function install-certfile() {
    local host="$1"
    local prefix="$2"
    local suffix="$3"
    local modifier=${4:-''}
    local target="${NODE_USERNAME}@${host}"
    kube-scp "${target}" "${LOCAL_CERTS_DIR}/${prefix}${modifier}.${suffix}" \
                       "${CERTS_TEMP_REMOTE_DIR}/${prefix}.${suffix}"
    kube-ssh "${target}" "sudo cp ${CERTS_TEMP_REMOTE_DIR}/${prefix}.${suffix} ${CERTS_REMOTE_DIR}/${prefix}.${suffix}"
}

function install-server-certs() {
  local host="$1"
  local prefix="$2"
  install-certfile ${host} ${prefix} key
  install-certfile ${host} ${prefix} crt
}

function install-client-certs() {
  local host="$1"
  local prefix="$2"
  install-certfile ${host} ${prefix} key "-${host}"
  install-certfile ${host} ${prefix} crt "-${host}"
}

function install-cert() {
  local host="$1"
  local prefix="$2"
  install-certfile ${host} ${prefix} crt
}

function install-private-key() {
  local host="$1"
  local prefix="$2"
  install-certfile ${host} ${prefix} key
}

function install-public-key() {
  local host="$1"
  local prefix="$2"
  install-certfile ${host} ${prefix} pub
}

function create-certs-dir {
    local host="$1"
    local target="${NODE_USERNAME}@${host}"
    kube-ssh "${target}" "mkdir -p ${CERTS_TEMP_REMOTE_DIR} && sudo mkdir -p ${CERTS_REMOTE_DIR}"
}

function contains() {
    local e
    for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
    return 1
}
