#!/usr/bin/env bash

NODE_IP=$1

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/env.sh

if [ -z "$NODE_IP" ]; then
    # FIXME(yuanying): Set KUBE_NODE_IP correctly
    NODE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
fi

ETCD_SERVICE=/etc/systemd/system/etcd.service
cat << EOF > ${ETCD_SERVICE}
[Unit]
Description=Etcd Container
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=-/usr/bin/docker stop etcd
ExecStartPre=-/usr/bin/docker rm etcd
ExecStartPre=/usr/bin/docker pull gcr.io/google_containers/etcd:3.0.14
ExecStart=/usr/bin/docker run --net=host --rm --name etcd \
    --volume=/var/etcd/data:/var/etcd/data:rw \
    gcr.io/google_containers/etcd:3.0.14 \
    /usr/local/bin/etcd \
    --listen-client-urls=http://0.0.0.0:2379 \
    --advertise-client-urls=http://10.0.0.6:2379 \
    --data-dir=/var/etcd/data

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable etcd
systemctl restart etcd
