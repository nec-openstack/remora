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

from remora.cluster import base
from remora.cluster import lb


class Cluster(base.BaseResourceTemplate):
    """docstring for Cluster."""
    def __init__(self, env, parameters):
        super(Cluster, self).__init__(parameters)
        self._env = env

    def _lb_provider(self):
        lb_parameters = self.parameters.get('loadbalancer', {})
        # TODO(yuanying): get default value from config
        lb_provider_type = lb_parameters.get('type', 'pseudo')
        return lb.DefaultLBProviderLoader().load(
            lb_provider_type,
            env=self.env,
            parameters=lb_parameters
        )

    @property
    def env(self):
        return self._env

    def schema(self):
        return None
