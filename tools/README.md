# Building tools

This tools directory contains shell scripts to setup Kubernetes cluster
on your baremetal or OpenStack VMs.

## Supported Linux distribution

-   Ubuntu 16.04
-   CoreOS

## Supported Container Runtime

-   Docker 1.12

## How to install Kubernetes

This document assumes that you have 4 machines on which Docker 1.12 is
already installed. And finally you will build a cluster of the following
composition.

-   VIP(192.168.1.101): VIP for accessing Kubernetes
-   Machine01(192.168.1.111): Kubernetes Master
-   Machine02(192.168.1.112): Kubernetes Master
-   Machine03(192.168.1.121): Kubernetes Worker
-   Machine04(192.168.1.122): Kubernetes Worker

### 1. Clone this repository and write config file

    $ git clone https://github.com/nec-openstack/remora.git
    $ cd remora
    $ cat <<-EOF > tools/env.sh
    # OS useraname which is used for ssh login.
    # This user also needs to sudo with no password.
    export NODE_USERNAME="ubuntu"
    export KUBERNETES_SERVICE_IP="192.168.1.101"
    export MASTERS="192.168.1.111 192.168.1.112"
    export WORKERS="192.168.1.121 192.168.1.122"
    export DISCOVERY_URL=$(curl "https://discovery.etcd.io/new?size=2")
    EOF

This config file specify ETCD/LB address and Kubernetes master/worker
addresses.

### 2. Generate and copy TLS assets

Kubernetes uses TLS to comunicate between node to node. So you have to
create these assets.

    $ export CLUSTER_NAME=my-cluster
    $ bash tools/generate-certs.sh
    $ bash tools/install-certs.sh

After this procedure, TLS certs are generated in `certs` directory, and
copied to correct node.

### 3. Install LB/Keepalived

If you want to build multi master node cluster, then LB is required.

    $ export CLUSTER_NAME=my-cluster
    $ bash tools/install-keepalived.sh

Note: This script attach `VIP` to one of masters. So if your cluster is
building under OpenStack, you have to configure `allowed-address-pairs`.
Check how to use `keepalived` on OpenStack environment.

### 4. Install Etcd

Etcd is also essential component for Kubernetes, but installing Etcd is
out of scope. So this script only install single node etcd for testing
purpose.

    $ export CLUSTER_NAME=my-cluster
    $ bash tools/install-etcd.sh

### 5. Install Kubernetes

Following command install Kubernetes masters and workers.

    $ export CLUSTER_NAME=my-cluster
    $ bash tools/install-k8s.sh
