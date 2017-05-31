#!/usr/bin/env bash

export NODE_IP=${1:-${NODE_IP}}
export _HOSTNAME=$(hostname)

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

ETCD_SERVICE=/etc/systemd/system/etcd.service
cat <<EOF > ${ETCD_SERVICE}
[Unit]
Description=Etcd Container
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=-${DOCKER_PATH} stop etcd
ExecStartPre=-${DOCKER_PATH} rm etcd
ExecStartPre=${DOCKER_PATH} pull ${ETCD_IMAGE_REPO}:${ETCD_V3_VERSION_TAG}
ExecStart=${DOCKER_PATH} run --net=host --rm --name etcd \
    --volume=/var/lib/etcd:/var/lib/etcd:rw \
    --volume=/etc/ssl/certs:/etc/ssl/certs:ro \
    --volume=/usr/share/ca-certificates:/usr/share/ca-certificates:ro \
    --volume=${ETCD_CERTS_DIR}:${ETCD_CERTS_DIR}:ro \
    ${ETCD_IMAGE_REPO}:${ETCD_V3_VERSION_TAG} \
    /usr/local/bin/etcd \
    --name=${_HOSTNAME} \
    --discovery=${DISCOVERY_URL} \
    --advertise-client-urls=https://${NODE_IP}:2379 \
    --initial-advertise-peer-urls=https://${NODE_IP}:2380 \
    --listen-client-urls=https://${NODE_IP}:2379,http://127.0.0.1:2379 \
    --listen-peer-urls=https://${NODE_IP}:2380 \
    --client-cert-auth=true \
    --cert-file=${ETCD_CERTS_DIR}/etcd.crt \
    --key-file=${ETCD_CERTS_DIR}/etcd.key \
    --trusted-ca-file=${ETCD_CERTS_DIR}/ca.crt \
    --peer-client-cert-auth=true \
    --peer-cert-file=${ETCD_CERTS_DIR}/etcd.crt \
    --peer-key-file=${ETCD_CERTS_DIR}/etcd.key \
    --peer-trusted-ca-file=${ETCD_CERTS_DIR}/ca.crt \
    --data-dir=/var/lib/etcd

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable etcd
systemctl restart etcd
