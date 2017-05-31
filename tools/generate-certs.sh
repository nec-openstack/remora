#!/usr/bin/env bash

set -eu
export LC_ALL=C

script_dir=`dirname $0`
source ${script_dir}/default-env.sh
source ${script_dir}/utils.sh

export CA_KEY=${CA_KEY:-"${LOCAL_CERTS_DIR}/ca.key"}
export CA_CERT=${CA_CERT:-"${LOCAL_CERTS_DIR}/ca.crt"}

echo "Generate CA key and cert"
bash ${script_dir}/gen-cert-ca.sh

for NODE in ${ETCDS}
do
    echo "Generate etcd server key and cert for ${NODE}"
    bash ${script_dir}/gen-cert-etcd-server.sh ${NODE}
done

for NODE in ${ETCD_PROXIES}
do
    echo "Generate etcd client key and cert for ${NODE}"
    bash ${script_dir}/gen-cert-client.sh \
        ${NODE} \
        etcd-client \
        "/CN=etcd-client"
done

echo "Generate apiserver key and cert"
bash ${ROOT}/gen-cert-apiserver.sh

echo "Generate service account keypairs"
bash ${ROOT}/gen-keypair-sa.sh

for NODE in ${MASTERS}
do
    echo "Generate admin key and cert for ${NODE}"
    bash ${script_dir}/gen-cert-client.sh \
        ${NODE} \
        admin \
        "/O=system:masters/CN=kubernetes-admin"
done

K8S_CLUSTER="${MASTERS} ${WORKERS}"
for NODE in ${K8S_CLUSTER}
do
    echo "Generate kubelet key and cert for ${NODE}"
    bash ${script_dir}/gen-cert-client.sh \
        ${NODE} \
        kubelet \
        "/O=system:nodes/CN=system:node:kubelet-${NODE//'.'/-}"
done

for NODE in ${KUBE_APISERVERS}
do
    echo "Generate apiserver kubelet client key and cert for ${NODE}"
    bash ${script_dir}/gen-cert-client.sh \
        ${NODE} \
        apiserver-kubelet-client \
        "/O=system:masters/CN=kube-apiserver-kubelet-client"
done

for NODE in ${KUBE_CONTROLLER_MANAGERS}
do
    echo "Generate controller-manager key and cert for ${NODE}"
    bash ${script_dir}/gen-cert-client.sh \
        ${NODE} \
        controller-manager \
        "/CN=system:kube-controller-manager"
done

for NODE in ${KUBE_SCHEDULERS}
do
    echo "Generate scheduler key and cert for ${NODE}"
    bash ${script_dir}/gen-cert-client.sh \
        ${NODE} \
        scheduler \
        "/CN=system:kube-scheduler"
done
