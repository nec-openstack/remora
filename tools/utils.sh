#!/usr/bin/env bash

set -eu
export LC_ALL=C

function calc_etcd_cluster_size {
  local cluster_size=0
  for MASTER in ${MASTERS}
  do
    cluster_size=$((cluster_size+1))
  done
  echo $cluster_size
}

function discovery_url {
  local ROOT=`dirname $0`
  local cache_file=${ETCD_DISCOVERY_URL_CACHE_FILE:-"${ROOT}/.discovery_url.cache"}
  local discovery_url=''

  if [[ -f ${cache_file} ]]; then
    discovery_url=$(cat ${cache_file})
  else
    local cluster_size=$(calc_etcd_cluster_size)
    discovery_url=$(curl "https://discovery.etcd.io/new?size=${cluster_size}")
    echo ${discovery_url} > ${cache_file}
  fi
  echo ${discovery_url}
}

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
