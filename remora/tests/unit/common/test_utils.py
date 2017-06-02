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


class TestUtilsTarGz(base.TestCase):

    def test_tar_gz(self):
        dirname = os.path.dirname(__file__)
        fixtures_dir = os.path.join(dirname, '..', 'fixtures', 'common')

        self.assertNotEqual(utils.tar_gz_base64(fixtures_dir), '')


class TestUtilsDecodeEnvDict(base.TestCase):

    def test_decode_env_dict_sigle_dict(self):
        prefix = 'kube'
        env = {
            "version": "v1.6.4"
        }
        expected_return = ["export KUBE_VERSION=\"v1.6.4\""]

        self.assertEqual(
            utils.decode_env_dict(prefix, env), expected_return
        )

    def test_decode_env_dict_with_list(self):
        prefix = 'kube'
        env = {
            "ips": ['192.168.1.11', '192.168.1.12']
        }
        expected_return = ["export KUBE_IPS=\"192.168.1.11 192.168.1.12\""]

        self.assertEqual(
            utils.decode_env_dict(prefix, env), expected_return
        )

    def test_decode_env_dict_multiple_value(self):
        prefix = 'kube'
        env = {
            "version": "v1.6.4",
            "ips": ['192.168.1.11', '192.168.1.12']
        }

        self.assertEqual(len(utils.decode_env_dict(prefix, env)), 2)
