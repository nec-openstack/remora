#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBE_TEMP="~/kube_temp"
SSH_OPTS="-oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -oLogLevel=ERROR"

# Run command over ssh
function kube-ssh() {
  local host="$1"
  shift
  ssh ${SSH_OPTS} -t "${host}" "$@" >/dev/null 2>&1
}

function kube-scp() {
  local host="$1"
  local src=($2)
  local dst="$3"
  scp -r ${SSH_OPTS} ${src[*]} "${host}:${dst}"
}
