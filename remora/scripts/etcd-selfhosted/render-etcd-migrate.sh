#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBE_TEMPLATE=${LOCAL_ETCD_MIGRATE_DIR}/etcd.yaml


cat << EOF > $KUBE_TEMPLATE
---
apiVersion: v1
kind: Service
metadata:
  name: bootstrap-etcd-service
  namespace: kube-system
spec:
  selector:
    k8s-app: boot-etcd
  clusterIP: ${ETCD_BOOTSTRAP_CLUSTER_IP}
  ports:
  - name: client
    port: 12379
    protocol: TCP
  - name: peers
    port: 12380
    protocol: TCP
---
{
  "apiVersion": "etcd.database.coreos.com/v1beta2",
  "kind": "EtcdCluster",
  "metadata": {
    "name": "kube-etcd",
    "namespace": "kube-system"
  },
  "spec": {
    "size": 1,
    "version": "${ETCD_VERSION}",
    "pod": {
      "nodeSelector": {
        "node-role.kubernetes.io/master": ""
      },
      "tolerations": [
        {
          "key": "node-role.kubernetes.io/master",
          "operator": "Exists",
          "effect": "NoSchedule"
        }
      ]
    },
    "selfHosted": {
      "bootMemberClientEndpoint": "https://${ETCD_BOOTSTRAP_CLUSTER_IP}:12379"
    },
    "TLS": {
      "static": {
        "member": {
          "peerSecret": "etcd-peer-tls",
          "serverSecret": "etcd-server-tls"
        },
        "operatorSecret": "etcd-client-tls"
      }
    }
  }
}
EOF
