#!/usr/bin/env bash

set -eu
export LC_ALL=C

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
    image: ${KUBE_HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION}
    command:
    - /hyperkube
    - apiserver
    - --bind-address=0.0.0.0
    - --insecure-port=0
    - --secure-port=${KUBE_INTERNAL_PORT}
    - --admission-control=${KUBE_ADMISSION_CONTROL}
    - --service-cluster-ip-range=${KUBE_SERVICE_IP_RANGE}
    - --service-account-key-file=${KUBE_CERTS_DIR}/sa.pub
    - --client-ca-file=${KUBE_CERTS_DIR}/ca.crt
    - --tls-cert-file=${KUBE_CERTS_DIR}/apiserver.crt
    - --tls-private-key-file=${KUBE_CERTS_DIR}/apiserver.key
    - --allow-privileged
    - --authorization-mode=RBAC
    - --advertise-address=${NODE_IP}
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    - --kubelet-client-key=${KUBE_CERTS_DIR}/apiserver-kubelet-client.key
    - --etcd-servers=${KUBE_ETCD_ENDPOINT}
    - --storage-backend=${KUBE_STORAGE_BACKEND}
    - --cloud-provider=${KUBE_CLOUD_PROVIDER:-""}
    - --cloud-config=${KUBE_CLOUD_CONFIG:-""}
    - --v=${KUBE_LOG_LEVEL:-"2"}
    livenessProbe:
      httpGet:
        host: 127.0.0.1
        port: 6443
        path: /healthz
        scheme: HTTPS
      initialDelaySeconds: 15
      timeoutSeconds: 15
    resources:
      requests:
        cpu: 250m
    volumeMounts:
    - mountPath: /etc/kubernetes
      name: k8s
      readOnly: true
    - mountPath: /etc/ssl/certs
      name: ssl-certs-host
      readOnly: true
  volumes:
  - hostPath:
      path: /etc/kubernetes
    name: k8s
  - hostPath:
      path: /etc/ssl/certs
    name: ssl-certs-host
EOF
