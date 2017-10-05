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
import sys

from fabric.api import env


__fabric_lib_dir = os.path.abspath(os.path.dirname(__file__))
__fabric_dir = os.path.join(__fabric_lib_dir, '..', '..')
__fabric_dir = os.path.abspath(__fabric_dir)
remora_scripts_dir = os.path.join(__fabric_dir, 'remora', 'scripts')
default_configs = os.path.join(__fabric_lib_dir, 'default.yaml')
configs = os.path.join(__fabric_dir, 'configs', '*.yaml')
ASSETS_DIR = os.path.join(remora_scripts_dir, 'assets')

LOCAL_ASSETS_PATH = {
    'ETCD_CA_KEY': 'certs/etcd/ca.key',
    'ETCD_CA_CERT': 'certs/etcd/ca.crt',
    'ETCD_CA_SERIAL': 'certs/etcd/ca.srl',
    'ETCD_CLIENT_KEY': 'certs/etcd/etcd-client.key',
    'ETCD_CLIENT_CERT': 'certs/etcd/etcd-client.crt',
    'ETCD_CLIENT_CERT_REQ': 'certs/etcd/etcd-client.csr',
    'KUBE_CA_KEY': 'certs/kubernetes/ca.key',
    'KUBE_CA_CERT': 'certs/kubernetes/ca.crt',
    'KUBE_CA_SERIAL': 'certs/kubernetes/ca.srl',
    'KUBE_SA_KEY': 'certs/kubernetes/sa.key',
    'KUBE_SA_PUB_KEY': 'certs/kubernetes/sa.pub',
    'KUBE_ADMIN_KEY': 'certs/kubernetes/admin.key',
    'KUBE_ADMIN_CERT': 'certs/kubernetes/admin.crt',
    'KUBE_ADMIN_CERT_REQ': 'certs/kubernetes/admin.csr',
    'KUBE_KUBELET_CLIENT_KEY': 'certs/kubernetes/kubelet-client.key',
    'KUBE_KUBELET_CLIENT_CERT': 'certs/kubernetes/kubelet-client.crt',
    'KUBE_KUBELET_CLIENT_CERT_REQ': 'certs/kubernetes/kubelet-client.csr',
    'KUBE_APISERVER_KEY': 'certs/kubernetes/apiserver.key',
    'KUBE_APISERVER_CERT': 'certs/kubernetes/apiserver.crt',
    'KUBE_APISERVER_CERT_REQ': 'certs/kubernetes/apiserver.csr',

    'KUBE_BOOTSTRAP_DIR': 'bootstrap',
    'KUBE_BOOTSTRAP_ASSETS_DIR': 'bootstrap/kubernetes',
    'KUBE_BOOTSTRAP_TEMP_DIR': 'bootstrap/kubernetes/bootstrap',
    'KUBE_BOOTSTRAP_CERTS_DIR': 'bootstrap/kubernetes/bootstrap/secrets',
    'KUBE_BOOTSTRAP_MANIFESTS_DIR': 'bootstrap/kubernetes/manifests',
}


def assets_dir():
    assets_dir = env.configs.get('local', {}).get('assets_dir', ASSETS_DIR)
    assets_dir = os.path.expanduser(assets_dir)
    return assets_dir


def certs_dir():
    certs_dir = os.path.join(assets_dir(), 'certs')
    return certs_dir


_mod = sys.modules[__name__]
for k, v in LOCAL_ASSETS_PATH.items():
    def wrapper(v):
        def _():
            return os.path.join(assets_dir(), v)
        return _
    setattr(_mod, k.lower(), wrapper(v))


def kubelet_asset_dir(node):
    return os.path.join(assets_dir(), 'kubelet', 'node-{}'.format(node))


def etcd_asset_dir(node):
    return os.path.join(assets_dir(), 'etcd', 'node-{}'.format(node))
