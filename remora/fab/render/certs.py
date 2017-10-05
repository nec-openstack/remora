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

from fabric.api import execute
from fabric.api import runs_once
from fabric.api import task
from fabric.operations import require

from remora.fab import helpers


@task
@runs_once
def etcd():
    require('stage')
    helpers.run_script(
        'certs/etcd/render.sh',
        local_env=helpers.generate_local_env()
    )


@task
@runs_once
def kubernetes_ca():
    require('stage')
    gen_certs_or_keypairs(
        'kubernetes',
        'gen-cert-ca.sh'
    )


@task(alias='sa')
@runs_once
def service_account():
    require('stage')
    gen_certs_or_keypairs(
        'kubernetes',
        'gen-keypair-sa.sh'
    )


@task
@runs_once
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
    )
    gen_client_certs(
        'kubernetes',
        'kubelet-client',
        '"/O=system:masters/CN=kube-kubelet-client"'
    )


@task(alias='k8s')
@runs_once
def kubernetes():
    require('stage')
    helpers.run_script(
        'certs/kubernetes/render.sh',
        local_env=helpers.generate_local_env()
    )


@task(default=True)
@runs_once
def all():
    execute(etcd)
    execute(kubernetes)
