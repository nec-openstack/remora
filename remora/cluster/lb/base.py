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

import abc

import six

from remora.cluster import base
from remora.common.loader import loadable


class LB(object):
    """docstring for LB."""
    def __init__(self,
                 v4address,
                 resource_ref,
                 heat_node_environment,
                 configure_script_content):
        super(LB, self).__init__()
        self._v4address = v4address
        self._resource_ref = resource_ref
        self._heat_node_enviroment = heat_node_environment
        self._configure_script_content = configure_script_content

    @property
    def v4address(self):
        return self._v4address

    @property
    def resource_ref(self):
        return self._resource_ref

    @property
    def heat_node_environment(self):
        return self._heat_node_enviroment

    @property
    def configure_script_content(self):
        return self._configure_script_content


@six.add_metaclass(abc.ABCMeta)
class BaseLBProvider(base.BaseResourceTemplate, loadable.Loadable):
    """docstring for BaseLBProvider."""
    def __init__(self, config, env={}, parameters={}):
        super(BaseLBProvider, self).__init__(parameters)
        super(base.BaseResourceTemplate, self).__init__(config)
        self._env = env

    @property
    def session(self):
        return self.env['session']

    @property
    def env(self):
        return self._env

    @abc.abstractmethod
    def build(self):
        raise NotImplementedError()

    @abc.abstractmethod
    def delete(self, resource_ref):
        raise NotImplementedError()

    @classmethod
    def get_config_opts(cls):
        return []
