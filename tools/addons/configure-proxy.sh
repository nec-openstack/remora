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
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: remora:node-proxier
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:node-proxier
subjects:
- kind: ServiceAccount
  name: kube-proxy
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kube-proxy
  namespace: kube-system
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: kube-proxy
  namespace: kube-system
  labels:
    app: kube-proxy
data:
  kubeconfig.conf: |
    apiVersion: v1
    kind: Config
    clusters:
    - cluster:
        certificate-authority: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        server: https://${KUBE_PUBLIC_SERVICE_IP}:${KUBE_PORT}
      name: default
    contexts:
    - context:
        cluster: default
        namespace: default
        user: default
      name: default
    current-context: default
    users:
    - name: default
      user:
        tokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  labels:
    k8s-app: kube-proxy
  name: kube-proxy
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: kube-proxy
  template:
    metadata:
      labels:
        k8s-app: kube-proxy
    spec:
      containers:
      - name: kube-proxy
        image: ${KUBE_HYPERKUBE_IMAGE_REPO}:${KUBE_VERSION}
        imagePullPolicy: IfNotPresent
        command:
        - /hyperkube
        - proxy
        - --kubeconfig=/var/lib/kube-proxy/kubeconfig.conf
        - --cluster-cidr=${KUBE_CLUSTER_CIDR}
        - --hostname-override=${NODE_IP}
        securityContext:
          privileged: true
        volumeMounts:
        - mountPath: /var/lib/kube-proxy
          name: kube-proxy
      hostNetwork: true
      serviceAccountName: kube-proxy
      # TODO: Why doesn't the Decoder recognize this new field and decode it properly? Right now it's ignored
      # tolerations:
      # - key: {{ .MasterTaintKey }}
      #   effect: NoSchedule
      volumes:
      - name: kube-proxy
        configMap:
          name: kube-proxy
EOF
