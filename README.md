# remora

Remora is command-line tool and library to manage kubernetes cluster on
any cloud and baremetal.

You can see [Quick Start Guide](doc/quickstart.md) which uses Vagrant to
install and run Kubernetes cluster.

## Prerequisite

You will need following softwares.

-   Python 3.5 or later and pip
-   kubectl 1.7.x or later

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

You will be working on a local machine that can `ssh` into each machines.

### 1. Clone this repository and write config file

Please clone this repository into your local machine.

```bash
$ git clone https://github.com/nec-openstack/remora.git
$ cd remora
$ cat <<-EOF > configs/cluster.yaml
---
# Username of target VMs
# If you use Ubuntu, change below line to like `user: ubuntu`.
user: core

local:
  assets_dir: "~/.kube/assets"

masters: &masters
  - 192.168.1.111
  - 192.168.1.112
workers: &workers
  - 192.168.1.121
  - 192.168.1.122

roledefs:
  bootstrap:
  - 192.168.1.111
  etcd: *masters
  master: *masters
  worker: *workers

kubernetes:
  # Public kubernetes service address
  public_service_ip: 192.168.1.101
EOF
```

This config file specify bootstrap host which boot Kubernetes cluster and
Kubernetes master/worker addresses.
And you can see some example config files in `configs` directory.
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

And also Remora will use `kubectl` command. So please install `kubectl`.

### 3. Generate assets

Following command will create the assets which are needed to build Kubernetes
cluster such as TLS certs, systemd unit files, Kubernetes manifests and
install scripts.

    $ fab cluster render

After this procedure, the assets are generated in `local.assets` directory.
You can modify these assets if you want.

### 4. Install Kubelet

Kubelet manages all components which are installed by remora. So it's needed
to install Kubelet first.

    $ fab cluster install.kubelet

### 5. Install Etcd

Etcd is also essential component for Kubernetes, but installing Etcd is
out of scope. So this script only install test grade etcd for testing
purpose.

    $ fab cluster install.etcd

### 6. Install Bootstrap Kubernetes

Remora will install Kubernetes cluster using Kubernetes itself, in other words,
Remora needs Bootstrap Kubernetes cluster before installing.
Following command create Bootstrap Kubernetes cluster.

    $ fab cluster install.bootstrap

### 7. Install Kubernetes

It's the time to install Real Kubernetes cluster.
Following command build Kubernetes cluster and cleanup Bootstrap Kubernetes
cluster.

    $ fab cluster install.kubernetes

## Check you cluster

You can access Kubernetes cluster easily.
Following command will setup you kubeconfig.

    $ fab cluster config

Then you can use `kubectl` command.

    $ kubectl version

That's all.
