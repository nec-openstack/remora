#!/usr/bin/env bash

set -eu
export LC_ALL=C

# export NODE_IP=$1

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
    image: ${HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION}
    command:
    - /hyperkube
    - controller-manager
    - --leader-elect
    - --master=http://127.0.0.1:8080
    - --root-ca-file=/etc/kubernetes/ssl/ca.pem
    - --service-account-private-key-file=/etc/kubernetes/ssl/apiserver-key.pem
    - --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem
    - --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem
    - --allocate-node-cidrs=true
    - --cluster-cidr=${KUBE_CLUSTER_CIDR}
    - --cloud-provider=${CLOUD_PROVIDER:-""}
    - --cloud-config=${CLOUD_CONFIG:-""}
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
    - mountPath: /etc/kubernetes
      name: k8s
      readOnly: true
    - mountPath: /etc/ssl/certs
      name: ssl-certs-host
      readOnly: true
  hostNetwork: true
  volumes:
  - hostPath:
      path: /etc/kubernetes
    name: k8s
  - hostPath:
      path: /etc/ssl/certs
    name: ssl-certs-host
EOF
