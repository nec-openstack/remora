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
ExecStartPre=${DOCKER_PATH} pull ${ETCD_IMAGE_REPO}:${ETCD_VERSION}
ExecStart=${DOCKER_PATH} run --net=host --rm --name etcd \
    --volume=/var/lib/etcd:/var/lib/etcd:rw \
    --volume=/etc/ssl/certs:/etc/ssl/certs:ro \
    --volume=/usr/share/ca-certificates:/usr/share/ca-certificates:ro \
    --volume=${ETCD_CERTS_DIR}:${ETCD_CERTS_DIR}:ro \
    ${ETCD_IMAGE_REPO}:${ETCD_VERSION} \
    /usr/local/bin/etcd \
    --name=${_HOSTNAME} \
    --proxy=on \
    --discovery=${ETCD_DISCOVERY_URL} \
    --listen-client-urls=http://127.0.0.1:2379 \
    --cert-file=${ETCD_CERTS_DIR}/etcd-client.crt \
    --key-file=${ETCD_CERTS_DIR}/etcd-client.key \
    --trusted-ca-file=${ETCD_CERTS_DIR}/ca.crt \
    --peer-cert-file=${ETCD_CERTS_DIR}/etcd-client.crt \
    --peer-key-file=${ETCD_CERTS_DIR}/etcd-client.key \
    --peer-trusted-ca-file=${ETCD_CERTS_DIR}/ca.crt

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable etcd
systemctl restart etcd
