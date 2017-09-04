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
from fabric.api import require
from fabric.api import runs_once
from fabric.api import sudo
from fabric.api import task

from remora.fab.clean import etcd
from remora.fab.clean import haproxy
from remora.fab.clean import kubernetes


@task
def dependency():
    require('stage')
    sudo('rm -rf {0}'.format(env.temp_dir))
    sudo('systemctl stop docker && systemctl disable docker')
    sudo('rm -rf /var/lib/docker')
    sudo('systemctl daemon-reload')
    sudo('systemctl enable docker && systemctl start docker')


@task(default=True)
@runs_once
def all():
    execute(etcd.all)
    execute(haproxy.all)
    execute(kubernetes.all)
    execute(dependency)
