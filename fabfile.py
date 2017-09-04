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
from fabric.api import roles
from fabric.api import runs_once
from fabric.api import task
from fabric.operations import require

from remora.fab import certs        # noqa
from remora.fab import clean        # noqa
from remora.fab import config       # noqa
from remora.fab import deploy       # noqa
from remora.fab import helpers


helpers.create_env_tasks(globals())

@task
@runs_once
def host(host=None):
    env['hosts'] = [host]

    for k, v in env.roledefs.items():
        if host in v:
            env.roledefs[k] = [host]
        else:
            env.roledefs[k] = []
