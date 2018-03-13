#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")

export SERVER_SUBJECT="/CN=kube-apiserver"
export SERVER_KEY=${KUBE_APISERVER_KEY}
export SERVER_CERT_REQ=${KUBE_APISERVER_CERT_REQ}
export SERVER_CERT=${KUBE_APISERVER_CERT}

SERVER_SANS="DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.cluster.local"
SERVER_SANS="${SERVER_SANS},IP:${KUBE_PUBLIC_SERVICE_IP},IP:${KUBE_PRIVATE_SERVICE_IP}"
SERVER_SANS="${SERVER_SANS},IP:127.0.0.1"
for HOSTNAME in ${KUBE_ADDITIONAL_HOSTNAMES}
do
    SERVER_SANS="${SERVER_SANS},DNS:${HOSTNAME}"
done
for IP in ${KUBE_ADDITIONAL_SERVICE_IPS}
do
    SERVER_SANS="${SERVER_SANS},IP:${IP}"
done
export SERVER_SANS

bash ${ROOT}/../gen-cert-server.sh
