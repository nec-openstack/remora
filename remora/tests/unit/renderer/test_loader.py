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


from remora.renderer.certs import etcd
from remora.renderer.certs import kubernetes
from remora.renderer import loader
from remora.renderer.manifests import apiserver
from remora.renderer.manifests import checkpointer
from remora.renderer.manifests import controller_manager
from remora.renderer.manifests import keepalived
from remora.renderer.manifests import proxy
from remora.renderer.manifests import scheduler
import remora.tests.unit.base as base


class TestDefaultCertsRendererLoader(base.TestCase):

    def test_renderer_available(self):
        renderer_loader = loader.DefaultCertsRendererLoader()
        renderers = [
            ('etcd', etcd.EtcdCertsRenderer),
            ('kubernetes', kubernetes.KubernetesCertsRenderer),
        ]

        for r in renderers:
            with self.subTest(r=r):
                renderer = renderer_loader.load(r[0])
                self.assertIsInstance(renderer, r[1])


class TestDefaultK8sManifestsRendererLoader(base.TestCase):

    def test_renderer_available(self):
        renderer_loader = loader.DefaultK8sManifestsRendererLoader()
        renderers = [
            ('kube_apiserver', apiserver.KubeApiServerRenderer),
            (
                'kube_controller_manager',
                controller_manager.KubeControllerManagerRenderer
            ),
            ('kube_scheduler', scheduler.KubeSchedulerRenderer),
            ('kube_proxy', proxy.KubeProxyRenderer),
            ('pod_checkpointer', checkpointer.PodCheckpointerRenderer),
            ('keepalived', keepalived.KeepalivedRenderer),
        ]

        for r in renderers:
            with self.subTest(r=r):
                renderer = renderer_loader.load(r[0], user_config={})
                self.assertIsInstance(renderer, r[1])
