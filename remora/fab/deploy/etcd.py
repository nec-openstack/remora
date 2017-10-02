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
from fabric.api import settings
from fabric.api import sudo
from fabric.api import task
from fabric.operations import require
import requests

from remora.fab.deploy import utils
from remora.fab import helpers


__all__ = ['server', 'proxy', 'all']


@task
@roles('etcd')
def fetch_discovery_url():
    with settings(warn_only=True):
        discovery_url = run('cat /etc/etcd/discovery_url')
    if not discovery_url.failed:
        env.etcd['discovery_url'] = discovery_url


@task
@roles('etcd')
def discovery_url():
    if 'discovery_url' in env.etcd:
        discovery_url = env.etcd['discovery_url']
    else:
        cluster_size = len(env.roledefs['etcd'])
        res = requests.get(
            env.etcd['discovery_service_url'].format(cluster_size)
        )
        discovery_url = env.etcd['discovery_url'] = res.text

    sudo('mkdir -p /etc/etcd')
    sudo('echo "{0}" > /etc/etcd/discovery_url'.format(discovery_url))


def resolve_discovery_url():
    if 'discovery_url' not in env.etcd:
        execute(fetch_discovery_url)
    if 'discovery_url' not in env.etcd:
        execute(discovery_url)


@task
@roles('etcd')
def server():
    require('stage')
    resolve_discovery_url()
    helpers.recreate_remote_temp_dir('etcd')
    utils.install_default_env('etcd', 'etcd')
    utils.install_scripts('etcd')
    utils.configure('etcd')


def etcd_servers_list():
    servers = ["{}:2379".format(s) for s in env.roledefs['etcd']]
    servers = ','.join(servers)
    return ['export ETCD_ENDPOINTS="{0}"'.format(servers)]


@task
@roles('etcd-proxy')
def proxy():
    if env.host not in env.roledefs.get('etcd-proxy', []):
        return

    require('stage')
    resolve_discovery_url()
    helpers.recreate_remote_temp_dir('etcd-proxy')
    utils.install_default_env('etcd-proxy', 'etcd', etcd_servers_list())
    utils.install_scripts('etcd-proxy')
    utils.configure('etcd-proxy')


@task(default=True)
@runs_once
def all():
    execute(server)
    execute(proxy)
