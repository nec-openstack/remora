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
#


class Client(object):

    def __init__(
        self,
        session=None,
        region_name=None,
        interface='public',
        verify=True,
        cacert=None,
    ):
        self.session = session
        self.region_name = region_name
        self.interface = interface
        self.verify = verify
        self.cacert = cacert
        self._env = None

    @property
    def env(self):
        if self._env is None:
            self._env = {
                'session': self.session,
                'region_name': self.region_name,
                'interface': self.interface,
                'verify': self.verify,
                'cacert': self.cacert,
            }

        return self._env
