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
    --proxy=on \
    --discovery=${DISCOVERY_URL} \
    --listen-client-urls=http://127.0.0.1:2379 \
    --cert-file=${ETCD_CERTS_DIR}/worker.pem \
    --key-file=${ETCD_CERTS_DIR}/worker-key.pem \
    --trusted-ca-file=${ETCD_CERTS_DIR}/ca.pem \
    --peer-cert-file=${ETCD_CERTS_DIR}/worker.pem \
    --peer-key-file=${ETCD_CERTS_DIR}/worker-key.pem \
    --peer-trusted-ca-file=${ETCD_CERTS_DIR}/ca.pem

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable etcd
systemctl restart etcd
