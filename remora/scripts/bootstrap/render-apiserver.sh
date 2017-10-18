#!/usr/bin/env bash

set -eu
export LC_ALL=C

if [[ ${ETCD_SELFHOSTED} == 'true' ]]; then
  ETCD_SERVERS="https://${ETCD_CLUSTER_IP}:2379,https://127.0.0.1:12379"
fi

export KUBE_API_TEMPLATE=${KUBE_BOOTSTRAP_MANIFESTS_DIR}/kube-apiserver.bootstrap.yaml
mkdir -p $(dirname $KUBE_API_TEMPLATE)
cat << EOF > $KUBE_API_TEMPLATE
apiVersion: v1
kind: Pod
metadata:
  name: bootstrap-kube-apiserver
  namespace: kube-system
spec:
  hostNetwork: true
  containers:
  - name: kube-apiserver
    image: ${KUBE_HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION}
    command:
    - /usr/bin/flock
    - /var/lock/api-server.lock
    - /hyperkube
    - apiserver
    - --admission-control=${KUBE_ADMISSION_CONTROL}
    - --advertise-address=\$(POD_IP)
    - --allow-privileged
    - --authorization-mode=Node,RBAC
    - --bind-address=0.0.0.0
    - --client-ca-file=/etc/kubernetes/secrets/kubernetes/ca.crt
    - --etcd-cafile=/etc/kubernetes/secrets/etcd/ca.crt
    - --etcd-certfile=/etc/kubernetes/secrets/etcd/etcd-client.crt
    - --etcd-keyfile=/etc/kubernetes/secrets/etcd/etcd-client.key
    - --etcd-quorum-read=true
    - --etcd-servers=${ETCD_SERVERS}
    - --insecure-port=0
    - --kubelet-client-certificate=/etc/kubernetes/secrets/kubernetes/kubelet-client.crt
    - --kubelet-client-key=/etc/kubernetes/secrets/kubernetes/kubelet-client.key
    - --secure-port=${KUBE_INTERNAL_PORT}
    - --service-account-key-file=/etc/kubernetes/secrets/kubernetes/sa.pub
    - --service-cluster-ip-range=${KUBE_SERVICE_IP_RANGE}
    - --cloud-provider=${KUBE_CLOUD_PROVIDER:-""}
    - --cloud-config=${KUBE_CLOUD_CONFIG:-""}
    - --storage-backend=${KUBE_STORAGE_BACKEND}
    - --tls-ca-file=/etc/kubernetes/secrets/kubernetes/ca.crt
    - --tls-cert-file=/etc/kubernetes/secrets/kubernetes/apiserver.crt
    - --tls-private-key-file=/etc/kubernetes/secrets/kubernetes/apiserver.key
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    - --v=${KUBE_LOG_LEVEL:-"2"}
    env:
    - name: POD_IP
      valueFrom:
        fieldRef:
          fieldPath: status.podIP
    volumeMounts:
    - mountPath: /etc/ssl/certs
      name: ssl-certs-host
      readOnly: true
    - mountPath: /etc/kubernetes/secrets
      name: secrets
      readOnly: true
    - mountPath: /var/lock
      name: var-lock
      readOnly: false
${KUBE_CLOUD_CONFIG_MOUNT:-""}
  volumes:
  - name: secrets
    hostPath:
      path: /etc/kubernetes/bootstrap/secrets
  - name: ssl-certs-host
    hostPath:
      path: /usr/share/ca-certificates
  - name: var-lock
    hostPath:
      path: /var/lock
${KUBE_CLOUD_CONFIG_VOLUME:-""}
EOF
