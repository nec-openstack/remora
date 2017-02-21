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


CM_TEMPLATE=/etc/kubernetes/manifests/kube-controller-manager.yaml
mkdir -p $(dirname $CM_TEMPLATE)
cat << EOF > $CM_TEMPLATE
apiVersion: v1
kind: Pod
metadata:
  name: kube-controller-manager
  namespace: kube-system
  labels:
    tier: control-plane
    component: kube-controller-manager
spec:
  containers:
  - name: kube-controller-manager
    image: ${HYPERKUBE_IMAGE_REPO}:${K8S_VER}
    command:
    - /hyperkube
    - controller-manager
    - --master=http://127.0.0.1:8080
    - --leader-elect=true
    - --service-account-private-key-file=${API_KEY_PATH}
    - --allocate-node-cidrs=true
    - --cluster-cidr=${POD_NETWORK}
    - --cloud-provider=openstack
    - --cloud-config=/etc/kubernetes/openstack.conf
    resources:
      requests:
        cpu: 200m
    livenessProbe:
      httpGet:
        host: 127.0.0.1
        path: /healthz
        port: 10252
      initialDelaySeconds: 15
      timeoutSeconds: 15
    volumeMounts:
    - mountPath: /etc/kubernetes/ssl
      name: ssl-certs-kubernetes
      readOnly: true
    - mountPath: /etc/ssl/certs
      name: ssl-certs-host
      readOnly: true
  hostNetwork: true
  volumes:
  - hostPath:
      path: /etc/kubernetes/ssl
    name: ssl-certs-kubernetes
  - hostPath:
      path: /usr/share/ca-certificates
    name: ssl-certs-host
EOF
