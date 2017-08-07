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
from fabric.api import execute
from fabric.api import lcd
from fabric.api import local
from fabric.api import roles
from fabric.api import runs_once
from fabric.api import task
from fabric.operations import require

from remora.common import utils
from remora.fab.certs import constants
from remora.fab import helpers

_CERTS_DIR = constants.CERTS_DIR
_LOCAL_ENV = [
    'export LOCAL_CERTS_DIR="%s"' % _CERTS_DIR,
]


def generate_local_env(target):
    certs_dir = os.path.join(_CERTS_DIR, target)
    return [
        'export LOCAL_CERTS_DIR="%s"' % certs_dir,
    ]


def gen_certs_or_keypairs(target, script_name, host='', *options):
    with tempfile.TemporaryDirectory() as temp_dir:
        default_env = os.path.join(temp_dir, 'default-env.sh')
        utils.generate_env_file(
            default_env,
            env,
            'kubernetes',
            generate_local_env(target)
        )

        with lcd(_CERTS_DIR):
            local(
                'source {0} && bash {1}/{2} {3} {4}'.format(
                    default_env,
                    helpers.remora_scripts_dir,
                    script_name,
                    host,
                    ' '.join(options)
                ),
                shell=env.local_shell,
            )


def gen_client_certs(target, *options):
    gen_certs_or_keypairs(
        target,
        'gen-cert-client.sh',
        env.host,
        *options
    )


@task
def etcd_ca():
    require('stage')
    gen_certs_or_keypairs(
        'etcd',
        'gen-cert-ca.sh'
    )


@task
def kubernetes_ca():
    require('stage')
    gen_certs_or_keypairs(
        'kubernetes',
        'gen-cert-ca.sh'
    )


@task
@roles('etcd')
def etcd_server():
    require('stage')
    gen_certs_or_keypairs(
        'etcd',
        'gen-cert-etcd-server.sh',
        env.host
    )


@task
@roles('etcd-proxy')
def etcd_client():
    require('stage')
    gen_client_certs(
        'etcd',
        'etcd-client',
        '"/CN=etcd-client"'
    )


@task
@runs_once
def etcd():
    execute(etcd_ca)
    execute(etcd_server)
    execute(etcd_client)


@task(alias='sa')
def service_account():
    require('stage')
    gen_certs_or_keypairs(
        'kubernetes',
        'gen-keypair-sa.sh'
    )


@task
@roles('apiserver', 'controller_manager', 'scheduler', 'worker')
def kubelet():
    require('stage')
    gen_client_certs(
        'kubernetes',
        'kubelet',
        '"/O=system:nodes/CN=system:node:kubelet"'
    )


@task
@roles('apiserver')
def apiserver():
    require('stage')
    gen_client_certs(
        'kubernetes',
        'admin',
        '"/O=system:masters/CN=kubernetes-admin"'
    )
    gen_certs_or_keypairs(
        'kubernetes',
        'gen-cert-apiserver.sh',
        env.host
    )
    gen_client_certs(
        'kubernetes',
        'apiserver-kubelet-client',
        '"/O=system:masters/CN=kube-apiserver-kubelet-client"'
    )


@task
@roles('controller_manager')
def controller_manager():
    require('stage')
    gen_client_certs(
        'kubernetes',
        'controller-manager',
        '"/CN=system:kube-controller-manager"'
    )


@task
@roles('scheduler')
def scheduler():
    require('stage')
    gen_client_certs(
        'kubernetes',
        'scheduler',
        '"/CN=system:kube-scheduler"'
    )


@task(alias='k8s')
@runs_once
def kubernetes():
    execute(kubernetes_ca)
    execute(service_account)
    execute(kubelet)
    execute(apiserver)
    execute(controller_manager)
    execute(scheduler)


@task(default=True)
@runs_once
def all():
    execute(etcd)
    execute(kubernetes)
