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

from openstack import connection
from openstack import profile
from oslo_log import log as logging

from remora.cluster.lb import base

NEUTRON_VERSION = '2.0'
LOG = logging.getLogger(__name__)


class FIPPseudoLBProvider(base.BaseLBProvider):

    """docstring for FIPPseudoLBProvider."""
    def __init__(self, env={}, params={}):
        super(FIPPseudoLBProvider, self).__init__(
            env=env,
            params=params,
        )
        session = env.get('session', None)
        interface = env.get('interface', 'public')
        region_name = env.get('region_name', None)
        verify = env.get('verify', True)
        # ca_cert = env.get('ca_cert', None)

        prof = profile.Profile()
        prof.set_region("network", region_name)
        prof.set_version("network", NEUTRON_VERSION)
        prof.set_interface("network", interface)
        conn = connection.Connection(authenticator=session.auth,
                                     verify=verify,
                                     cert=session.cert,
                                     profile=prof)
        LOG.debug('Connection: %s', conn)
        LOG.debug('Network client initialized using OpenStack SDK: %s',
                  conn.network)

        self.neutron = conn.network

    def build(self):
        # TODO(yuanying): get default floating network from env and conf
        floating_network = self.params.get('floating_network', None)
        floating_network = self.neutron.find_network(floating_network,
                                                     ignore_missing=False)
        attrs = {}
        attrs['floating_network_id'] = floating_network.id
        return self.neutron.create_ip(**attrs)

    def delete(self, resource_ref):
        raise NotImplementedError()

    def schema(self):
        return None
