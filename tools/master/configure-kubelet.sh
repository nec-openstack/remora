#!/usr/bin/env bash

set -eu
export LC_ALL=C

# export NODE_IP=$1
# export ETCD_ADDRESS=$2
#
# export ETCD_ENDPOINTS=http://${ETCD_ADDRESS}:2379
# export K8S_VER=v1.5.3
# export HYPERKUBE_IMAGE_REPO=gcr.io/google_containers/hyperkube
#
# export POD_NETWORK=10.2.0.0/16
# export SERVICE_IP_RANGE=10.254.0.0/24
# export K8S_SERVICE_IP=10.254.0.1
# export DNS_SERVER_IP=10.254.0.10

# TODO(yuanying): Set --cloud-provider=openstack --cloud-config=/etc/kubernetes/openstack.conf

KUBELET_SERVICE=/etc/systemd/system/kubelet.service
cat << EOF > ${KUBELET_SERVICE}
[Unit]
Description=Kubelet Container
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
Restart=always
ExecReload=/usr/bin/docker restart kubelet
ExecStartPre=-/usr/bin/docker stop kubelet
ExecStartPre=-/usr/bin/docker rm kubelet
ExecStartPre=/usr/bin/docker pull ${HYPERKUBE_IMAGE_REPO}:${K8S_VER}
ExecStart=/usr/bin/docker run \
    --name=kubelet \
    --volume=/:/rootfs:ro \
    --volume=/sys:/sys:ro \
    --volume=/dev:/dev \
    --volume=/var/lib/docker/:/var/lib/docker:ro \
    --volume=/var/lib/kubelet/:/var/lib/kubelet:rw \
    --volume=/var/run:/var/run:rw \
    --volume=/etc/kubernetes:/etc/kubernetes:ro \
    --net=host \
    --pid=host \
    --privileged=true \
    ${HYPERKUBE_IMAGE_REPO}:${K8S_VER} \
    /hyperkube kubelet \
        --api-servers=http://127.0.0.1:8080 \
        --allow-privileged=true \
        --register-schedulable=false \
        --network-plugin=kubenet \
        --hairpin-mode=promiscuous-bridge \
        --hostname-override=${NODE_IP} \
        --pod-manifest-path=/etc/kubernetes/manifests \
        --pod-cidr=10.253.0.0/24 \
        --non-masquerade-cidr=${POD_NETWORK} \
        --cluster-dns=${DNS_SERVER_IP} \
        --cluster-domain=cluster.local \
        --cloud-provider=openstack \
        --cloud-config=/etc/kubernetes/openstack.conf
[Install]
WantedBy=multi-user.target
EOF
