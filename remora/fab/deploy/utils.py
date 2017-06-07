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
import tempfile

from fabric.api import env
from fabric.api import put
from fabric.api import sudo

from remora.common import utils
from remora.fab import helpers


def remote_temp_dir(target):
    return helpers.remote_temp_dir(target)


def local_scripts_files(target):
    return os.path.join(helpers.remora_scripts_dir, target, '*')


def install_default_env(target, package, additional_env_list=[]):
    with tempfile.NamedTemporaryFile() as temp:
        utils.generate_env_file(
            temp.name,
            env,
            package,
            additional_env_list
        )
        put(
            temp.name,
            os.path.join(remote_temp_dir(target), 'default-env.sh')
        )


def configure_script(target):
    return os.path.join(remote_temp_dir(target), 'configure.sh')


def install_scripts(target):
    put(
        local_scripts_files(target),
        remote_temp_dir(target)
    )
    sudo("chmod +x {0}".format(configure_script(target)))


def configure(target):
    sudo("{0} {1}".format(configure_script(target), env.host))
