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

from fabric.api import parallel
from fabric.api import require
from fabric.api import settings
from fabric.api import sudo
from fabric.api import task

from remora.fab.clean import utils


@task(default=True)
@parallel
def all():
    require('stage')
    script = 'ip link show dev {0} > /dev/null 2>&1 && ip link delete dev {0}'
    with settings(warn_only=True):
        utils.disable_service('kubelet', 'kubernetes')
        sudo(script.format('cni0'))
        sudo(script.format('flannel.1'))
        sudo(
            'file {0} > /dev/null 2>&1 && sudo rm -rf {0}'.format(
                '/run/flannel'
            )
        )
