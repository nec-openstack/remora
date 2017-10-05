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
from fabric.api import roles
from fabric.api import runs_once
from fabric.api import task
from fabric.operations import require

from remora.fab import constants
from remora.fab import helpers


def render(script_name, *options):
    helpers.run_script(
        script_name,
        *options,
        local_env=helpers.generate_local_env()
    )


@task(default=True)
@runs_once
def all():
    execute(bootstrap)


@task
@runs_once
@roles('bootstrap')
def bootstrap():
    require('stage')
    render(
        'bootstrap/render.sh',
        env.host
    )
    local('cp -r {0}/* {1}'.format(
        constants.certs_dir(),
        constants.kube_bootstrap_certs_dir()
    ))
