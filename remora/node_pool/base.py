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

from common import template


@six.add_metaclass(abc.ABCMeta)
class BaseNodePoolTemplate(template.BaseTemplate):

    def __init__(self, params):
        super(BaseNodePoolTemplate, self).__init__(params)


@six.add_metaclass(abc.ABCMeta)
class BaseNodePool(object):
    """docstring for BaseNodePool."""
    def __init__(self):
        super(BaseNodePool, self).__init__()


class HeatNodePool(BaseNodePool):
    """docstring for HeatNodePool."""
    def __init__(self, arg):
        super(HeatNodePool, self).__init__()
