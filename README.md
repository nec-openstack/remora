# remora

Remora is command-line tool and library to manage kubernetes cluster on
any cloud and baremetal.

Please fill here a long description which must be at least 3 lines wrapped on
80 cols, so that distribution package maintainers can use it in their packages.
Note that this is a hard requirement.

* Free software: Apache license
* Documentation: http://docs.openstack.org/developer/remora
* Source: http://git.openstack.org/cgit/openstack/remora
* Bugs: http://bugs.launchpad.net/remora

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

```bash
$ git clone https://github.com/nec-openstack/remora.git
$ cd remora
$ cat <<-EOF > configs/cluster.yaml
---
# Username of target VMs
# If you use Ubuntu, change below line to like `user: ubuntu`.
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
  worker: *workers

haproxy:
  # network range which keepalived use
  keepalived_net_range: 16
  # network interface which keepalived use
  keepalived_net_device: eth0

kubernetes:
  # Public kubernetes service address
  public_service_ip: 192.168.1.101
EOF
```

This config file specify ETCD/LB address and Kubernetes master/worker
addresses. And you can see some example config files in `configs` directory.
`configs/openstack.yaml` tells you how to setup single master node cluster
on the top of OpenStack.

> *Notes*: Remora uses `fabric` to setup kubernetes cluster. And these config
> files are used for specifying target cluster.
> If you put `configs/hoge.yaml` file under configs directory, Remora will
> create `hoge` sub-task to specify hoge cluster.

### 2. Install dependencies

Remora requires some dependencies, so it's needed to install.

```bash
$ pip install -r requirements.txt
```

### 3. Generate and copy TLS assets

Kubernetes uses TLS to comunicate between node to node. So you have to
create these assets.

    $ fab cluster certs

After this procedure, TLS certs are generated in `tools/certs` directory, and
copied to correct node.

### 4. Install Kubelet

Kubelet manages all components which are installed by remora. So it's needed
to install Kubelet first.

    $ fab cluster deploy.kubelet

### 5. Install LB/Keepalived

If you want to build multi master node cluster, then LB is required.

    $ fab cluster deploy.haproxy

Note: This script attach `VIP` to one of masters. So if your cluster is
building under OpenStack, you have to configure `allowed-address-pairs`.
Check how to use `keepalived` on OpenStack environment.

### 6. Install Etcd

Etcd is also essential component for Kubernetes, but installing Etcd is
out of scope. So this script only install test grade etcd for testing
purpose.

    $ fab cluster deploy.etcd

### 7. Install Kubernetes

Following command install Kubernetes master components.

    $ fab cluster deploy.kubernetes
