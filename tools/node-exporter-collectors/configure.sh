#!/usr/bin/env bash

export NODE_IP=${1:-${NODE_IP}}

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")
source ${ROOT}/default-env.sh

SMARMON_SERVICE=/etc/systemd/system/node-exporter-smartmon.service
cat <<EOF > ${SMARMON_SERVICE}
[Unit]
Description=Collect smart data to /var/lib/node-exporter
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
ExecStartPre=-${DOCKER_PATH} stop node-exporter-smartmon
ExecStartPre=-${DOCKER_PATH} rm node-exporter-smartmon
ExecStartPre=${DOCKER_PATH} pull yuanying/node-exporter-smartmon:latest
ExecStart=/bin/sh -c '${DOCKER_PATH} run --rm --name node-exporter-smartmon \
    --privileged \
    yuanying/node-exporter-smartmon:latest \
    2>&1 > /var/lib/node-exporter/smartmon.prom.tmp && \
    mv /var/lib/node-exporter/smartmon.prom.tmp /var/lib/node-exporter/smartmon.prom'

[Install]
WantedBy=multi-user.target
EOF

SMARMON_TIMER=/etc/systemd/system/node-exporter-smartmon.timer
cat <<EOF > ${SMARMON_TIMER}
[Unit]
Description=Run node-exporter-smartmon service every 10 minutes

[Timer]
OnCalendar=*:0/10
EOF

systemctl daemon-reload
systemctl enable node-exporter-smartmon
systemctl enable node-exporter-smartmon.timer
systemctl restart node-exporter-smartmon
systemctl restart node-exporter-smartmon.timer
