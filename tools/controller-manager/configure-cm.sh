#!/usr/bin/env bash

set -eu
export LC_ALL=C

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
    image: ${KUBE_HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION}
    command:
    - /hyperkube
    - controller-manager
    - --leader-elect
    - --use-service-account-credentials=true
    - --root-ca-file=${KUBE_CERTS_DIR}/ca.crt
    - --kubeconfig=/etc/kubernetes/controller-manager.yaml
    - --service-account-private-key-file=${KUBE_CERTS_DIR}/sa.key
    - --cluster-signing-cert-file=${KUBE_CERTS_DIR}/ca.crt
    - --cluster-signing-key-file=${KUBE_CERTS_DIR}/ca.key
    - --allocate-node-cidrs=true
    - --cluster-cidr=${KUBE_CLUSTER_CIDR}
    - --node-cidr-mask-size=${KUBE_NODE_CIDR_MASK_SIZE}
    - --cloud-provider=${KUBE_CLOUD_PROVIDER:-""}
    - --cloud-config=${KUBE_CLOUD_CONFIG:-""}
    - --v=${KUBE_LOG_LEVEL:-"2"}
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
    resources:
      requests:
        cpu: 200m
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
