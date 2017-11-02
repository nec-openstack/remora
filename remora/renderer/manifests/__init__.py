#
#   Licensed under the Apache License, Version 2.0 (the "License"); you may
#   not use this file except in compliance with the License. You may obtain
#   a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#   WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#   License for the specific language governing permissions and limitations
#   under the License.

import abc
import os
import six

from remora.common import assets


MANIFESTS_DIR = "kubernetes/manifests"


def manifests_dir(user_config):
    return os.path.join(assets.assets_dir(user_config), MANIFESTS_DIR)


def templates_dir():
    return os.path.join(
        os.path.abspath(os.path.dirname(__file__)),
        'templates'
    )


@six.add_metaclass(abc.ABCMeta)
class BaseRenderer(object):
    file_path = None
    template_path = None

    def __init__(self, user_config={}):
        super(BaseRenderer, self).__init__()
        self.user_config = user_config

    # @abc.abstractmethod
    def render(self):
        pass

    def _file_path(self):
        return os.path.join(
            manifests_dir(self.user_config),
            self.file_path
        )

    def _template_path(self):
        return os.path.join(
            templates_dir(),
            self.template_path
        )
