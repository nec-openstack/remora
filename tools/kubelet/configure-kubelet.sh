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
ExecStartPre=${DOCKER_PATH} pull ${KUBE_HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION}
ExecStartPre=${DOCKER_PATH} run --rm -v /opt/cni/bin:/cnibindir \
    ${KUBE_HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION} \
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
    ${KUBE_HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION} \
    /hyperkube kubelet \
        --allow-privileged=true \
        --register-node=true \
        --hostname-override=${NODE_IP} \
        --pod-manifest-path=/etc/kubernetes/manifests \
        --network-plugin=${KUBE_NETWORK_PLUGIN} \
        --cni-conf-dir=/etc/cni/net.d \
        --non-masquerade-cidr=${KUBE_CLUSTER_CIDR} \
        --cluster-dns=${KUBE_CLUSTER_DNS_IP} \
        --cluster-domain=cluster.local \
        --kubeconfig=/etc/kubernetes/kubelet.yaml \
        --require-kubeconfig=true \
        --cloud-provider=${KUBE_CLOUD_PROVIDER:-""} \
        --cloud-config=${KUBE_CLOUD_CONFIG:-""} \
        --authorization-mode=Webhook \
        --client-ca-file=${KUBE_CERTS_DIR}/ca.crt \
        --v=${KUBE_LOG_LEVEL:-"2"}

[Install]
WantedBy=multi-user.target
EOF
