#!/usr/bin/env bash

set -eu
export LC_ALL=C

# export NODE_IP=$1
# export MASTER_ADDRESS=$2
#
# export K8S_VER=v1.5.3
# export HYPERKUBE_IMAGE_REPO=gcr.io/google_containers/hyperkube
#
# export POD_NETWORK=10.2.0.0/16
# export SERVICE_IP_RANGE=10.254.0.0/24
# export K8S_SERVICE_IP=10.254.0.1
# export DNS_SERVER_IP=10.254.0.10

KUBE_PROXY_TEMPLATE=/etc/kubernetes/manifests/kube-proxy.yaml
mkdir -p $(dirname $KUBE_PROXY_TEMPLATE)
cat << EOF > $KUBE_PROXY_TEMPLATE
apiVersion: v1
kind: Pod
metadata:
  name: kube-proxy
  namespace: kube-system
  # This annotation ensures that kube-proxy does not get evicted if the node
  # supports critical pod annotation based priority scheme.
  # Note that kube-proxy runs as a static pod so this annotation does NOT have
  # any effect on rescheduler (default scheduler and rescheduler are not
  # involved in scheduling kube-proxy).
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ''
  labels:
    tier: node
    component: kube-proxy
spec:
  hostNetwork: true
  containers:
  - name: kube-proxy
    image: ${HYPERKUBE_IMAGE_REPO}:${K8S_VER}
    command:
    - /hyperkube
    - proxy
    - --master=http://${MASTER_ADDRESS}:8080
    - --cluster-cidr=${POD_NETWORK}
    - --hostname-override=${NODE_IP}
    securityContext:
      privileged: true
    volumeMounts:
    - mountPath: /etc/ssl/certs
      name: ssl-certs-host
      readOnly: true
    - mountPath: /var/run/dbus
      name: dbus
      readOnly: false
  volumes:
  - hostPath:
      path: /usr/share/ca-certificates
    name: ssl-certs-host
  - hostPath:
      path: /var/run/dbus
    name: dbus
EOF
