#!/usr/bin/env bash

set -eu
export LC_ALL=C

# export NODE_IP=$1

KUBELET_SERVICE=/etc/systemd/system/kubelet.service
cat << EOF > ${KUBELET_SERVICE}
[Unit]
Description=Kubelet Container
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
Restart=always
ExecReload=${DOCKER_PATH} restart kubelet
ExecStartPre=-${DOCKER_PATH} stop kubelet
ExecStartPre=-${DOCKER_PATH} rm kubelet
ExecStartPre=${DOCKER_PATH} pull ${HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION}
ExecStartPre=${DOCKER_PATH} run --rm -v /opt/cni/bin:/cnibindir \
    ${HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION} \
        /bin/cp -r /opt/cni/bin/. /cnibindir/
ExecStart=${DOCKER_PATH} run \
    --name=kubelet \
    --volume=/:/rootfs:ro \
    --volume=/sys:/sys:ro \
    --volume=/dev:/dev \
    --volume=/var/lib/docker/:/var/lib/docker:rw \
    --volume=/var/lib/kubelet/:/var/lib/kubelet:shared \
    --volume=/var/run:/var/run:rw \
    --volume=/etc/kubernetes:/etc/kubernetes:ro \
    --volume=/etc/cni/net.d:/etc/cni/net.d:ro \
    --volume=/opt/cni/bin:/opt/cni/bin:ro \
    --net=host \
    --pid=host \
    --privileged=true \
    --restart=on-failure:5 \
    ${HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION} \
    /hyperkube kubelet \
        --allow-privileged=true \
        --register-schedulable=false \
        --hostname-override=${NODE_IP} \
        --pod-manifest-path=/etc/kubernetes/manifests \
        --network-plugin=cni \
        --cni-conf-dir=/etc/cni/net.d \
        --cluster-dns=${KUBE_DNS_SERVER_IP} \
        --cluster-domain=cluster.local \
        --kubeconfig=/etc/kubernetes/kubelet.yaml \
        --require-kubeconfig=true \
        --cloud-provider=${CLOUD_PROVIDER:-""} \
        --cloud-config=${CLOUD_CONFIG:-""}
[Install]
WantedBy=multi-user.target
EOF
