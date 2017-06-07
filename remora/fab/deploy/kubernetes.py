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

from fabric.api import env
from fabric.api import roles
from fabric.api import runs_once
from fabric.api import task
from fabric.operations import require

from remora.common import utils as common_utils
from remora.fab.deploy import utils
from remora.fab import helpers


@task(default=True)
def all():
    execute(kubelet)
    execute(apiserver)
    execute(controller_manager)
    execute(scheduler)
    execute(network)
    execute(addons)


@task
@roles('apiserver', 'controller_manager', 'scheduler', 'worker')
def kubelet():
    require('stage')
    helpers.recreate_remote_temp_dir('kubelet')
    utils.install_default_env('kubelet', 'kubernetes')
    utils.install_scripts('kubelet')
    utils.configure('kubelet')


@task
@roles('apiserver')
def apiserver():
    require('stage')
    helpers.recreate_remote_temp_dir('apiserver')
    utils.install_default_env('apiserver', 'kubernetes')
    utils.install_scripts('apiserver')
    utils.configure('apiserver')


@task
@roles('controller_manager')
def controller_manager():
    require('stage')
    helpers.recreate_remote_temp_dir('controller-manager')
    utils.install_default_env('controller-manager', 'kubernetes')
    utils.install_scripts('controller-manager')
    utils.configure('controller-manager')


@task
@roles('scheduler')
def scheduler():
    require('stage')
    helpers.recreate_remote_temp_dir('scheduler')
    utils.install_default_env('scheduler', 'kubernetes')
    utils.install_scripts('scheduler')
    utils.configure('scheduler')


@task
@roles('apiserver')
@runs_once
def addons():
    require('stage')
    helpers.recreate_remote_temp_dir('addons')
    utils.install_default_env('addons', 'kubernetes')
    utils.install_scripts('addons')
    utils.configure('addons')


def generate_network_env_list():
    env_list = []
    if env.kubernetes['network_plugin'] != 'cni':
        return env_list

    if env.kubernetes['cni_plugin'] in env:
        cni_plugin = env.kubernetes['cni_plugin']
        env_list.extend(
            common_utils.decode_env_dict(cni_plugin, env[cni_plugin])
        )

    return env_list

@task
@roles('apiserver')
@runs_once
def network():
    require('stage')
    helpers.recreate_remote_temp_dir('network')
    utils.install_default_env(
        'network',
        'kubernetes',
        generate_network_env_list()
    )
    utils.install_scripts('network')
    utils.configure('network')
