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

from remora.common import exception


def assets_dir(user_config):
    assets_dir = user_config['spec']['local'].get('assets_dir', None)
    if assets_dir is None:
        raise exception.AssetsDirNotSpecified()

    assets_dir = os.path.expanduser(assets_dir)
    assets_dir = os.path.abspath(assets_dir)
    return assets_dir
