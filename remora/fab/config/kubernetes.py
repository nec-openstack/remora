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

import base64
import os

from fabric.api import env
from fabric.api import local
from fabric.api import roles
from fabric.api import runs_once
from fabric.api import task
from fabric.operations import require

from remora.fab import constants


@task
@runs_once
def all():
    require('stage')
    certs_dir = constants.certs_dir()
    ca = local(
        'cat {0}/kubernetes/ca.crt 2>/dev/null'.format(certs_dir),
        capture=True,
    )
    ca = base64.b64encode(ca.encode('utf-8')).decode('utf-8')
    admin_crt = local(
        'cat {0}/kubernetes/admin.crt 2>/dev/null'.format(certs_dir),
        capture=True,
    )
    admin_crt = base64.b64encode(admin_crt.encode('utf-8')).decode('utf-8')
    admin_key = local(
        'cat {0}/kubernetes/admin.key 2>/dev/null'.format(certs_dir),
        capture=True,
    )
    admin_key = base64.b64encode(admin_key.encode('utf-8')).decode('utf-8')

    api_address = env['configs']['kubernetes']['public_service_ip']
    api_port = env['configs']['kubernetes']['port']
    api_endpoint = 'https://{0}:{1}'.format(api_address, api_port)
    kubeconfig = os.path.expanduser(env['configs']['local']['kubeconfig'])
    local_kubectl = env['configs']['local']['kubectl']

    local(
        "{kubectl} config set-cluster {cluster} \
        --server={api_endpoint} \
        --kubeconfig={kube_config}".format(
            kubectl=local_kubectl,
            kube_config=kubeconfig,
            cluster=env.stage,
            api_endpoint=api_endpoint,
        )
    )
    local(
        '{kubectl} config set \
        clusters.{cluster}.certificate-authority-data \
        "{ca}" \
        --kubeconfig={kube_config}'.format(
            kubectl=local_kubectl,
            kube_config=kubeconfig,
            cluster=env.stage,
            ca=ca,
        )
    )

    local(
        "{kubectl} config set-credentials {cluster}-admin \
        --kubeconfig={kube_config}".format(
            kubectl=local_kubectl,
            kube_config=kubeconfig,
            cluster=env.stage,
        )
    )
    local(
        '{kubectl} config set \
        users.{cluster}-admin.client-certificate-data \
        "{admin_crt}" \
        --kubeconfig={kube_config}'.format(
            kubectl=local_kubectl,
            kube_config=kubeconfig,
            cluster=env.stage,
            admin_crt=admin_crt,
        )
    )
    local(
        '{kubectl} config set \
        users.{cluster}-admin.client-key-data \
        "{admin_key}" \
        --kubeconfig={kube_config}'.format(
            kubectl=local_kubectl,
            kube_config=kubeconfig,
            cluster=env.stage,
            admin_key=admin_key,
        )
    )
    local(
        "{kubectl} config set-context {cluster} \
        --cluster={cluster} --user={cluster}-admin \
        --kubeconfig={kube_config}".format(
            kubectl=local_kubectl,
            kube_config=kubeconfig,
            cluster=env.stage,
        )
    )

    local(
        "{kubectl} config use-context {cluster} \
        --kubeconfig={kube_config}".format(
            kubectl=local_kubectl,
            kube_config=kubeconfig,
            cluster=env.stage,
        )
    )
