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
from fabric.api import execute
from fabric.api import task
from fabric.operations import require

from remora.fab.deploy import utils
from remora.fab import helpers


@task(default=True)
def all():
    execute(kubelet)


@task
def kubelet():
    require('stage')
    helpers.recreate_remote_temp_dir('kubelet')
    utils.install_default_env(
        'kubelet',
        'kubernetes',
        generate_cloud_provider_env_list()
    )
    utils.install_scripts('kubelet')
    utils.configure('kubelet')


def generate_cloud_provider_env_list():
    env_list = []
    cloud_provider = env.kubernetes['cloud_provider']
    if cloud_provider == '':
        return env_list

    if cloud_provider in env:
        env_list.extend(
            common_utils.decode_env_dict(cloud_provider, env[cloud_provider])
        )

    return env_list
