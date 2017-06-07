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

### 0. Install dependencies

```bash
$ pip install -r requirements.txt
```

### 1. Clone this repository and write config file

```bash
$ git clone https://github.com/nec-openstack/remora.git
$ cd remora
$ cat <<-EOF > configs/cluster.yaml
---
user: core

masters: &masters
  - 192.168.1.111
  - 192.168.1.112
workers: &workers
  - 192.168.1.121
  - 192.168.1.122

roledefs:
  haproxy: *masters
  etcd: *masters
  apiserver: *masters
  controller_manager: *masters
  scheduler: *masters
  etcd-proxy: *workers
  worker: *workers

haproxy:
  # network range which keepalived use
  keepalived_net_range: 16
  # network interface which keepalived use
  keepalived_net_device: eth0

kubernetes:
  public_service_ip: 192.168.1.101
EOF
```

This config file specify ETCD/LB address and Kubernetes master/worker
addresses.

### 2. Generate and copy TLS assets

Kubernetes uses TLS to comunicate between node to node. So you have to
create these assets.

    $ fab cluster certs

After this procedure, TLS certs are generated in `tools/certs` directory, and
copied to correct node.

### 3. Install LB/Keepalived

If you want to build multi master node cluster, then LB is required.

    $ fab cluster deploy.haproxy

Note: This script attach `VIP` to one of masters. So if your cluster is
building under OpenStack, you have to configure `allowed-address-pairs`.
Check how to use `keepalived` on OpenStack environment.

### 4. Install Etcd

Etcd is also essential component for Kubernetes, but installing Etcd is
out of scope. So this script only install single node etcd for testing
purpose.

    $ fab cluster deploy.etcd

### 5. Install Kubernetes

Following command install Kubernetes masters and workers.

    $ fab cluster deploy.kubernetes
