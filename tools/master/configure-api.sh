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

export KUBE_API_TEMPLATE=/etc/kubernetes/manifests/kube-apiserver.yaml
mkdir -p $(dirname $KUBE_API_TEMPLATE)
cat << EOF > $KUBE_API_TEMPLATE
apiVersion: v1
kind: Pod
metadata:
  name: kube-apiserver
  namespace: kube-system
  labels:
    tier: control-plane
    component: kube-apiserver
spec:
  hostNetwork: true
  containers:
  - name: kube-apiserver
    image: ${HYPERKUBE_IMAGE_REPO}:${K8S_VER}
    command:
    - /hyperkube
    - apiserver
    - --bind-address=0.0.0.0
    - --insecure-bind-address=0.0.0.0
    - --etcd-servers=${ETCD_ENDPOINTS}
    - --allow-privileged=true
    - --service-cluster-ip-range=${SERVICE_IP_RANGE}
    - --secure-port=0
    - --advertise-address=${NODE_IP}
    - --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota
    - --service-account-key-file=${API_KEY_PATH}
    - --runtime-config=extensions/v1beta1/networkpolicies=true
    - --anonymous-auth=false
    - --cloud-provider=openstack
    - --cloud-config=/etc/kubernetes/openstack.conf
    livenessProbe:
      httpGet:
        host: 127.0.0.1
        port: 8080
        path: /healthz
      initialDelaySeconds: 15
      timeoutSeconds: 15
    ports:
    - containerPort: 443
      hostPort: 443
      name: https
    - containerPort: 8080
      hostPort: 8080
      name: local
    volumeMounts:
    - mountPath: /etc/kubernetes/ssl
      name: ssl-certs-kubernetes
      readOnly: true
    - mountPath: /etc/ssl/certs
      name: ssl-certs-host
      readOnly: true
  volumes:
  - hostPath:
      path: /etc/kubernetes/ssl
    name: ssl-certs-kubernetes
  - hostPath:
      path: /usr/share/ca-certificates
    name: ssl-certs-host
EOF
