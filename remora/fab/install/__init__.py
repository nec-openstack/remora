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
from fabric.api import local
from fabric.api import parallel
from fabric.api import put
from fabric.api import roles
from fabric.api import runs_once
from fabric.api import sudo
from fabric.api import task
from fabric.operations import require

from remora.fab import constants
from remora.fab import helpers


@task(default=True)
@runs_once
def all():
    execute(kubelet)
    execute(etcd)
    execute(bootstrap)
    execute(kubernetes)


def install(target, local_files):
    require('stage')
    helpers.recreate_remote_temp_dir(target)
    local_files = os.path.join(
        constants.assets_dir(),
        local_files,
    )
    remote_temp_dir = helpers.remote_temp_dir(target)
    put(local_files, remote_temp_dir)
    sudo("bash {0}/{1}".format(remote_temp_dir, 'install.sh'))


@task
@parallel
def kubelet():
    install(
        'kubelet',
        os.path.join('kubelet', 'node-{}'.format(env.host), '*')
    )


@task
@roles('etcd')
def etcd():
    install(
        'etcd',
        os.path.join('etcd', 'node-{}'.format(env.host), '*')
    )


@task
@roles('bootstrap')
def bootstrap():
    install(
        'bootstrap',
        os.path.join('bootstrap', '*')
    )


@task
@roles('bootstrap')
def kubernetes():
    local(
        "{} {}/install.sh".format(
            env.configs['local']['shell'], constants.kube_assets_dir()
        )
    )
    local(
        "{} {}/cluster-check.sh".format(
            env.configs['local']['shell'], constants.kube_assets_dir()
        )
    )
    sudo('rm -rf /etc/kubernetes/manifests/*.bootstrap.yaml')
    sudo('rm -rf /etc/kubernetes/manifests/bootstrap')
