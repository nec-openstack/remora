#!/usr/bin/env bash

set -eu
export LC_ALL=C

KUBE_TEMPLATE=${LOCAL_MANIFESTS_DIR}/kube-keepalived.yaml

cat << EOF > $KUBE_TEMPLATE
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-keepalived
  namespace: kube-system
data:
  keepalived.cfg: |
    vrrp_instance VI {
      state BACKUP
      interface ${HAPROXY_KEEPALIVED_NET_DEVICE}
      garp_master_delay 5
      virtual_router_id ${HAPROXY_KEEPALIVED_VRID:-"1"}
      priority 101
      nopreempt
      advert_int 1
      authentication {
        auth_type PASS
        auth_pass ${HAPROXY_KEEPALIVED_AUTH_PASSWORD:-'himitsu'}
      }
      virtual_ipaddress {
        ${KUBE_PUBLIC_SERVICE_IP}/${HAPROXY_KEEPALIVED_NET_RANGE}   dev ${HAPROXY_KEEPALIVED_NET_DEVICE}
      }
    }
  haproxy.cfg: |
    global
            quiet
            maxconn 2048
    defaults
            mode    tcp
            balance leastconn
            timeout client      30m
            timeout server      30m
            timeout connect     3000ms
            retries 3
    frontend kube_api
            bind 0.0.0.0:${KUBE_PORT}
            default_backend kube_api_backend
    backend kube_api_backend
            option tcp-check
EOF

size=1
for address in ${HAPROXY_BACKENDS}; do
    echo "            server api${size} ${address}:${KUBE_INTERNAL_PORT} check" >> ${KUBE_TEMPLATE}
    size=$((size+1))
done

cat << EOF >> $KUBE_TEMPLATE
---
apiVersion: "extensions/v1beta1"
kind: DaemonSet
metadata:
  name: kube-keepalived
  namespace: kube-system
  labels:
    tier: control-plane
    k8s-app: kube-keepalived
spec:
  template:
    metadata:
      labels:
        tier: control-plane
        k8s-app: kube-keepalived
      annotations:
        checkpointer.alpha.coreos.com/checkpoint: "true"
        scheduler.alpha.kubernetes.io/critical-pod: ''
    spec:
      containers:
      - name: bootstrap-keepalived
        image: yuanying/keepalived:latest
        securityContext:
          capabilities:
            add: ["NET_ADMIN", "NET_BROADCAST"]
        volumeMounts:
        - mountPath: /etc/keepalived/keepalived.cfg
          subPath: keepalived.cfg
          name: kube-keepalived-config
          readOnly: true
        - mountPath: /var/lock
          name: var-lock
          readOnly: false
        command:
        - /usr/bin/flock
        - /var/lock/keepalived.lock
        - -c
        - "/usr/sbin/keepalived -f /etc/keepalived/keepalived.cfg -l -D -P -n"
      - name: bootstrap-haproxy
        image: haproxy:alpine
        volumeMounts:
        - mountPath: /usr/local/etc/haproxy/haproxy.cfg
          subPath: haproxy.cfg
          name: kube-keepalived-config
          readOnly: true
        - mountPath: /var/lock
          name: var-lock
          readOnly: false
        command:
        - /usr/bin/flock
        - /var/lock/haproxy.lock
        - -c
        - "haproxy -f /usr/local/etc/haproxy/haproxy.cfg"
      volumes:
      - name: kube-keepalived-config
        configMap:
          name: kube-keepalived
      - name: var-lock
        hostPath:
          path: /var/lock
      hostNetwork: true
      nodeSelector:
        node-role.kubernetes.io/master: ""
      tolerations:
      - key: CriticalAddonsOnly
        operator: Exists
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
  updateStrategy:
    rollingUpdate:
      maxUnavailable: 1
    type: RollingUpdate
EOF
