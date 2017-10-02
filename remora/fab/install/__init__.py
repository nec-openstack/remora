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
from fabric.api import sudo
from fabric.api import task
from fabric.operations import require

from remora.fab import constants
from remora.fab import helpers


@task(default=True)
def all():
    execute(kubelet)


@task
def kubelet():
    require('stage')
    helpers.recreate_remote_temp_dir("kubelet")
    local_files = os.path.join(
        constants.assets_dir(),
        'kubelet',
        'node-{}'.format(env.host),
        '*'
    )
    remote_temp_dir = helpers.remote_temp_dir("kubelet")
    put(local_files, remote_temp_dir)
    sudo("bash {0}/{1}".format(remote_temp_dir, 'install.sh'))
