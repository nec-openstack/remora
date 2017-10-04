#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBE_TEMPLATE=${LOCAL_MANIFESTS_DIR}/etcd-assets.yaml

ETCD_CA=$(cat ${LOCAL_ASSETS_DIR}/certs/etcd/ca.crt | base64)
ETCD_SERVER_CERT=$(cat ${LOCAL_ASSETS_DIR}/certs/etcd/etcd.crt | base64)
ETCD_SERVER_KEY=$(cat ${LOCAL_ASSETS_DIR}/certs/etcd/etcd.key | base64)
ETCD_CLIENT_CERT=$(cat ${LOCAL_ASSETS_DIR}/certs/etcd/etcd-client.crt | base64)
ETCD_CLIENT_KEY=$(cat ${LOCAL_ASSETS_DIR}/certs/etcd/etcd-client.key | base64)

cat << EOF > $KUBE_TEMPLATE
---
apiVersion: v1
data:
  server-ca.crt: ${ETCD_CA}
  server.crt: ${ETCD_SERVER_CERT}
  server.key: ${ETCD_SERVER_KEY}
kind: Secret
metadata:
  name: etcd-server-tls
  namespace: kube-system
type: Opaque
---
apiVersion: v1
data:
  etcd-client-ca.crt: ${ETCD_CA}
  etcd-client.crt: ${ETCD_CLIENT_CERT}
  etcd-client.key: ${ETCD_CLIENT_KEY}
kind: Secret
metadata:
  name: etcd-client-tls
  namespace: kube-system
type: Opaque
---
apiVersion: v1
data:
  peer-ca.crt: ${ETCD_CA}
  peer.crt: ${ETCD_SERVER_CERT}
  peer.key: ${ETCD_SERVER_KEY}
kind: Secret
metadata:
  name: etcd-peer-tls
  namespace: kube-system
type: Opaque
---
apiVersion: v1
kind: Service
metadata:
  name: etcd-service
  namespace: kube-system
  # This alpha annotation will retain the endpoints even if the etcd pod isn't ready.
  # This feature is always enabled in endpoint controller in k8s even it is alpha.
  annotations:
    service.alpha.kubernetes.io/tolerate-unready-endpoints: "true"
spec:
  selector:
    app: etcd
    etcd_cluster: kube-etcd
  clusterIP: ${ETCD_CLUSTER_IP}
  ports:
  - name: client
    port: 2379
    protocol: TCP

EOF
