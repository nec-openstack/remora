# Play with Vagrant

You can also test `Remora` with Vagrant.

## Prerequisite

You will need following softwares.

-   Python 3.5 or later and pip
-   kubectl 1.7.x or later

### Install Python and pip

```bash
$ sudo apt install curl llvm sqlite3 libssl-dev libbz2-dev libreadline-dev libsqlite3-dev libncurses5-dev libncursesw5-dev python-tk python3-tk tk-dev
$ git clone https://github.com/yyuu/pyenv.git ~/.pyenv
$ cat <<-'EOF' >> ~/.bash_profile
export PYENV_ROOT=$HOME/.pyenv
export PATH=$PYENV_ROOT/bin:$PATH
eval "$(pyenv init -)"
EOF
$ source ~/.bash_profile
$ pyenv install 3.5.3
$ pyenv global 3.5.3
$ curl -kL https://bootstrap.pypa.io/get-pip.py | python
```

### Install kubectl

```bash
$ curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
$ chmod +x ./kubectl
$ sudo mv ./kubectl /usr/local/bin/kubectl
```

## Install Kubernetes Cluster using Remora

### Install Remora

```bash
$ git clone https://github.com/nec-openstack/remora.git
$ cd remora
$ pip install -r requirements.txt
```

### Install Kubernetes Cluster

```bash
$ vagrant up
$ fab vagrant render
$ fab vagrant install
```

### Access your Kubernetes Cluster

```bash
$ fab vagrant config
$ kubectl version
```
