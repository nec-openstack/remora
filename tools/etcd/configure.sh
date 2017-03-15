#!/usr/bin/env bash

export NODE_IP=${1:-${NODE_IP}}

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

ETCD_SERVICE=/etc/systemd/system/etcd.service
cat << EOF > ${ETCD_SERVICE}
[Unit]
Description=Etcd Container
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=-${DOCKER_PATH} stop etcd
ExecStartPre=-${DOCKER_PATH} rm etcd
ExecStartPre=${DOCKER_PATH} pull gcr.io/google_containers/etcd:3.0.14
ExecStart=${DOCKER_PATH} run --net=host --rm --name etcd \
    --volume=/var/etcd/data:/var/etcd/data:rw \
    gcr.io/google_containers/etcd:3.0.14 \
    /usr/local/bin/etcd \
    --listen-client-urls=http://0.0.0.0:2379 \
    --advertise-client-urls=http://${NODE_IP}:2379 \
    --data-dir=/var/etcd/data

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable etcd
systemctl restart etcd
