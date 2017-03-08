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

import remora.common.utils as utils
import remora.tests.unit.base as base


class TestUtils(base.TestCase):

    def test_tar_gz(self):
        dirname = os.path.dirname(__file__)
        fixtures_dir = os.path.join(dirname, '..', 'fixtures', 'common')

        self.assertNotEqual(utils.tar_gz_base64(fixtures_dir), '')
