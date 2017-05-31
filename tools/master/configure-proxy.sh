#!/usr/bin/env bash
# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -eu
export LC_ALL=C

# export NODE_IP=$1

KUBE_PROXY_TEMPLATE=/etc/kubernetes/addons/kube-proxy.yaml
mkdir -p $(dirname $KUBE_PROXY_TEMPLATE)
cat << EOF > $KUBE_PROXY_TEMPLATE
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: k8s-proxy-v1
  namespace: kube-system
  labels:
    component: kube-proxy
    k8s-app: kube-proxy
    kubernetes.io/cluster-service: "true"
    name: kube-proxy
    tier: node
spec:
  selector:
    matchLabels:
      component: kube-proxy
      k8s-app: kube-proxy
      kubernetes.io/cluster-service: "true"
      name: kube-proxy
      tier: node
  template:
    metadata:
      annotations:
        scheduler.alpha.kubernetes.io/affinity: '{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"beta.kubernetes.io/arch","operator":"In","values":["amd64"]}]}]}}}'
        scheduler.alpha.kubernetes.io/tolerations: '[{"key":"dedicated","value":"master","effect":"NoSchedule"}]'
      labels:
        component: kube-proxy
        k8s-app: kube-proxy
        kubernetes.io/cluster-service: "true"
        name: kube-proxy
        tier: node
    spec:
      hostNetwork: true
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
      containers:
      - name: kube-proxy
        image: ${HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION}
        command:
        - /hyperkube
        - proxy
        - --kubeconfig=/etc/kubernetes/kubelet.yaml
        - --cluster-cidr=${KUBE_CLUSTER_CIDR}
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
        - mountPath: /etc/kubernetes/kubelet.yaml
          name: "kubeconfig"
          readOnly: true
        - mountPath: ${KUBE_CERTS_DIR}
          name: "etc-kube-ssl"
          readOnly: true
      volumes:
      - hostPath:
          path: /etc/ssl/certs
        name: ssl-certs-host
      - hostPath:
          path: /var/run/dbus
        name: dbus
      - name: "kubeconfig"
        hostPath:
          path: "/etc/kubernetes/kubelet.yaml"
      - name: "etc-kube-ssl"
        hostPath:
          path: "${KUBE_CERTS_DIR}"
EOF
