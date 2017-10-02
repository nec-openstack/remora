#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

import os

from fabric.api import env
from fabric.api import execute
from fabric.api import put
from fabric.api import require
from fabric.api import roles
from fabric.api import runs_once
from fabric.api import sudo
from fabric.api import task

from remora.fab.certs import constants
from remora.fab import helpers


def remote_certs_dir(target):
    return env[target]['certs_dir']


def mkdirs(target):
    helpers.recreate_remote_temp_dir("certs/{0}".format(target))
    sudo("mkdir -p {0}".format(remote_certs_dir(target)))


def install_file(target, prefix, suffix, modifier=''):
    local_file = "{0}{1}.{2}".format(prefix, modifier, suffix)
    local_path = os.path.join(constants.certs_dir(), target, local_file)
    remote_file = "{0}.{1}".format(prefix, suffix)
    remote_temp_path = os.path.join(
        helpers.remote_temp_dir("certs/{0}".format(target)),
        remote_file
    )
    remote_path = os.path.join(remote_certs_dir(target), remote_file)
    put(local_path, remote_temp_path)
    sudo('cp {0} {1}'.format(remote_temp_path, remote_path))


def install_certs(target, prefix):
    install_file(target, prefix, 'key')
    install_file(target, prefix, 'crt')


def install_indivisual_certs(target, prefix):
    install_file(target, prefix, 'key', "-{0}".format(env.host))
    install_file(target, prefix, 'crt', "-{0}".format(env.host))


def install_cert(target, prefix):
    install_file(target, prefix, 'crt')


def install_private_key(target, prefix):
    install_file(target, prefix, 'key')


def install_public_key(target, prefix):
    install_file(target, prefix, 'pub')


@task
@runs_once
def etcd():
    execute(etcd_server)
    execute(etcd_client)


@task
@roles('etcd')
def etcd_server():
    require('stage')
    mkdirs('etcd')
    install_cert('etcd', 'ca')
    install_certs('etcd', 'etcd')


@task
def etcd_client():
    require('stage')
    mkdirs('etcd')
    install_cert('etcd', 'ca')
    install_certs('etcd', 'etcd-client')


def install_kube_common():
    require('stage')
    mkdirs('kubernetes')
    install_cert('kubernetes', 'ca')
    install_indivisual_certs('kubernetes', 'kubelet')


@task
@roles('apiserver')
def apiserver():
    install_public_key('kubernetes', 'sa')
    install_certs('kubernetes', 'admin')
    install_certs('kubernetes', 'apiserver')
    install_certs('kubernetes', 'apiserver-kubelet-client')


@task
@roles('controller_manager')
def controller_manager():
    install_private_key('kubernetes', 'ca')
    install_private_key('kubernetes', 'sa')
    install_certs('kubernetes', 'controller-manager')


@task
@roles('scheduler')
def scheduler():
    install_certs('kubernetes', 'scheduler')


@task
def kubelet():
    install_kube_common()


@task(alias='k8s')
@runs_once
def kubernetes():
    execute(kubelet)
    execute(apiserver)
    execute(controller_manager)
    execute(scheduler)


@task(default=True)
@runs_once
def all():
    execute(etcd)
    execute(kubernetes)
