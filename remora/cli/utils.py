# -*- encoding: utf-8 -*-
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


def get_client(obj):
    if hasattr(obj.app, 'client_manager'):
        # NOTE(sileht): cliff objects loaded by OSC
        return obj.app.client_manager.coe
    else:
        # TODO(sileht): Remove this when OSC is able
        # to install the gnocchi client binary itself
        return obj.app.client
