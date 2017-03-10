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

from neutronclient.neutron import client as neutron_client

from remora.cluster.lb import base

NEUTRON_VERSION = '2.0'


class FIPPseudoLBProvider(base.BaseLBProvider):

    """docstring for FIPPseudoLBProvider."""
    def __init__(self, config, env={}, parameters={}):
        super(FIPPseudoLBProvider, self).__init__(
            config,
            env=env,
            parameters=parameters,
        )
        self.neutron_client = neutron_client.Client(
            NEUTRON_VERSION,
            session=env.get('session', None),
            endpoint_type=env.get('interface', 'public'),
            region_name=env.get('region_name', None),
            insecure=not env.get('verify', True),
            ca_cert=env.get('ca_cert', None)
        )

    def build(self):
        raise NotImplementedError()

    def delete(self, resource_ref):
        raise NotImplementedError()

    def schema(self):
        return None
