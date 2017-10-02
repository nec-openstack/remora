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

from fabric.api import settings
from fabric.api import sudo

from remora.fab import helpers


def disable_service(service, config_dir_basename=None):
    if config_dir_basename is None:
        config_dir_basename = service

    with settings(warn_only=True):
        sudo('systemctl stop {0} && systemctl disable {0}'.format(service))
    sudo('rm -rf /etc/systemd/system/{0}*'.format(service))
    sudo('rm -rf /etc/{0}'.format(config_dir_basename))
    sudo('rm -rf {0}'.format(helpers.remote_temp_dir(service)))
    sudo('systemctl daemon-reload')
