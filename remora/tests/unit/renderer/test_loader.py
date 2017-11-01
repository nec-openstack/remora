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

import copy
import os

from remora.renderer import loader
from remora.renderer.certs import etcd
from remora.renderer.certs import kubernetes
import remora.tests.unit.base as base


class TestDefaultCertsRendererLoader(base.TestCase):

    def test_etcd_certs_renderer_available(self):
        renderer_loader = loader.DefaultCertsRendererLoader()
        etcd_certs_renderer = renderer_loader.load('etcd')
        self.assertIsInstance(etcd_certs_renderer, etcd.EtcdCertsRenderer)

    def test_k8s_certs_renderer_available(self):
        renderer_loader = loader.DefaultCertsRendererLoader()
        k8s_certs_renderer = renderer_loader.load('kubernetes')
        self.assertIsInstance(
            k8s_certs_renderer,
            kubernetes.KubernetesCertsRenderer
        )
