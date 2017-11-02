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
from fabric.api import run
from fabric.api import runs_once
from fabric.api import task
from fabric.operations import require

from remora.fab import helpers


def etcd_env_list():
    etcd_initial_cluster = [
        "{}=https://{}:2380".format(v, k) for k, v in env.etcd_hosts.items()
    ]
    etcd_initial_cluster = ','.join(etcd_initial_cluster)
    return [
        'export ETCD_NODE_NAME={}'.format(env.etcd_hosts[env.host]),
        'export ETCD_INITIAL_CLUSTER={}'.format(etcd_initial_cluster),
    ] + helpers.generate_local_env()


def render(script_name, *options):
    helpers.run_script(
        script_name,
        *options,
        local_env=etcd_env_list()
    )


@task(default=True)
@runs_once
def all():
    require('stage')
    if helpers.is_selfhosted_etcd():
        execute(etcd_selfhosted)
    else:
        execute(correct_hostname)
        execute(etcd)


@task
@runs_once
def correct_hostname():
    hostnames = env.configs.get('etcd', {}).get('hosts', None)
    if hostnames is None:
        hostnames = {}
        etcds = env.roledefs.get('etcd', [])
        for etcd in etcds:
            hostnames[etcd] = etcd
    env['etcd_hosts'] = hostnames


@task
@roles('etcd')
def etcd():
    require('stage')
    if not helpers.is_selfhosted_etcd():
        render(
            'etcd/render.sh',
            env.host
        )


@task
@runs_once
def etcd_selfhosted():
    require('stage')
    if helpers.is_selfhosted_etcd():
        render(
            'etcd-selfhosted/render.sh',
            env.host
        )
