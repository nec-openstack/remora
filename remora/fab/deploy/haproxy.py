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
from fabric.api import task
from fabric.operations import require

from remora.fab.deploy import utils
from remora.fab import helpers


def apiserver_list():
    servers = ' '.join(env.roledefs['apiserver'])
    return ['export HAPROXY_BACKENDS="{0}"'.format(servers)]


@task(default=True)
@roles('haproxy')
def all():
    require('stage')
    helpers.recreate_remote_temp_dir('haproxy')
    utils.install_default_env('haproxy', 'haproxy', apiserver_list())
    utils.install_scripts('haproxy')
    utils.configure('haproxy')
