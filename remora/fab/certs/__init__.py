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

from fabric.api import execute
from fabric.api import task

from remora.fab import helpers

CERTS_DIR = os.path.join(helpers.remora_scripts_dir, 'certs')

from remora.fab.certs import generate  # noqa
from remora.fab.certs import install   # noqa


@task(default=True)
def all():
    execute(generate.all)
    execute(install.all)
