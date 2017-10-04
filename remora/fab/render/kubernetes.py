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
from fabric.api import runs_once
from fabric.api import task
from fabric.operations import require

from remora.fab import constants
from remora.fab import helpers


def generate_local_env():
    return helpers.generate_local_env() + apiserver_list()


def apiserver_list():
    servers = ' '.join(env.roledefs['master'])
    return ['export HAPROXY_BACKENDS="{0}"'.format(servers)]


def render(script_name, *options):
    helpers.run_script(
        script_name,
        *options,
        local_env=generate_local_env()
    )


@task(default=True)
@runs_once
def all():
    execute(proxy)
    execute(network)
    execute(dns)
    execute(apiserver)
    execute(controller_manager)
    execute(scheduler)
    execute(checkpointer)
    execute(keepalived)
    execute(etcd_selfhosted)


@task
@runs_once
def apiserver():
    require('stage')
    render(
        'apiserver/render.sh',
        env.host
    )


@task
@runs_once
def controller_manager():
    require('stage')
    render(
        'controller-manager/render.sh',
        env.host
    )


@task
@runs_once
def scheduler():
    require('stage')
    render(
        'scheduler/render.sh',
        env.host
    )


@task
@runs_once
def checkpointer():
    require('stage')
    render(
        'checkpointer/render.sh',
        env.host
    )


@task
@runs_once
def keepalived():
    require('stage')
    render(
        'keepalived/render.sh',
        env.host
    )


@task
@runs_once
def etcd_selfhosted():
    require('stage')
    render(
        'etcd-selfhosted/render.sh',
        env.host
    )


@task
@runs_once
def proxy():
    require('stage')
    render(
        'kube-proxy/render.sh',
        env.host
    )


@task
@runs_once
def dns():
    require('stage')
    render(
        'kube-dns/render.sh',
        env.host
    )


@task
@runs_once
def network():
    require('stage')
    render(
        'network/render.sh',
        env.host
    )
