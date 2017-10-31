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


import remora.common.merge_dicts as merge_dicts
import remora.tests.unit.base as base


class TestMergeDicts(base.TestCase):

    def test_merge_dicts_both_has_key(self):
        expected_return = {'kubernetes': 'value-1'}
        dict1 = {'kubernetes': 'value-1'}
        dict2 = {'kubernetes': 'value-default'}

        actual_return = merge_dicts.merge_dicts(dict1, dict2)
        self.assertEqual(expected_return, actual_return)

    def test_merge_dicts_dict1_has_no_key(self):
        expected_return = {'kubernetes': 'value-default'}
        dict1 = {}
        dict2 = {'kubernetes': 'value-default'}

        actual_return = merge_dicts.merge_dicts(dict1, dict2)
        self.assertEqual(expected_return, actual_return)

    def test_merge_dicts_dict2_has_no_key(self):
        expected_return = {'kubernetes': 'value-1'}
        dict1 = {'kubernetes': 'value-1'}
        dict2 = {}

        actual_return = merge_dicts.merge_dicts(dict1, dict2)
        self.assertEqual(expected_return, actual_return)

    def test_merge_dicts_nested_dict(self):
        expected_return = {'kubernetes': {'sub-1': 'sub-value-1'}}
        dict1 = {'kubernetes': {'sub-1': 'sub-value-1'}}
        dict2 = {'kubernetes': {'sub-1': 'sub-value-default'}}

        actual_return = merge_dicts.merge_dicts(dict1, dict2)
        self.assertEqual(expected_return, actual_return)

    def test_merge_dicts_dict1_has_no_nested_dict(self):
        expected_return = {'kubernetes': {'sub-1': 'sub-value-default'}}
        dict1 = {'kubernetes': {}}
        dict2 = {'kubernetes': {'sub-1': 'sub-value-default'}}

        actual_return = merge_dicts.merge_dicts(dict1, dict2)
        self.assertEqual(expected_return, actual_return)

    def test_merge_dicts_dict2_has_no_nested_dict(self):
        expected_return = {'kubernetes': {'sub-1': 'sub-value-1'}}
        dict1 = {'kubernetes': {'sub-1': 'sub-value-1'}}
        dict2 = {'kubernetes': {}}

        actual_return = merge_dicts.merge_dicts(dict1, dict2)
        self.assertEqual(expected_return, actual_return)

    def test_merge_dicts_both_has_list_value(self):
        expected_return = {'kubernetes': ['value-1', 'value-2', 'value-3']}
        dict1 = {'kubernetes': ['value-1', 'value-2']}
        dict2 = {'kubernetes': ['value-3']}

        actual_return = merge_dicts.merge_dicts(dict1, dict2)
        self.assertEqual(expected_return, actual_return)

    def test_merge_dicts_exists_duplicated_value_in_list(self):
        expected_return = {'kubernetes': ['value-1', 'value-2', 'value-3']}
        dict1 = {'kubernetes': ['value-1', 'value-2', 'value-3']}
        dict2 = {'kubernetes': ['value-3']}

        actual_return = merge_dicts.merge_dicts(dict1, dict2)
        self.assertEqual(expected_return, actual_return)

    def test_merge_dicts_exists_dict_in_list(self):
        expected_return = {'kubernetes': ['value-1', 'value-2',
                           {'sub-1': 'sub-value-1'}]}
        dict1 = {'kubernetes': ['value-1', 'value-2']}
        dict2 = {'kubernetes': [{'sub-1': 'sub-value-1'}]}

        actual_return = merge_dicts.merge_dicts(dict1, dict2)
        self.assertEqual(expected_return, actual_return)

    def test_merge_dicts_exists_complex_dict_in_list(self):
        expected_return = {'kubernetes': ['value-1', 'value-2',
                           {'sub-1': ['sub-value-1', 'sub-value-default']}]}
        dict1 = {'kubernetes': ['value-1', 'value-2',
                 {'sub-1': ['sub-value-1']}]}
        dict2 = {'kubernetes': [{'sub-1': ['sub-value-default']}]}

        actual_return = merge_dicts.merge_dicts(dict1, dict2)
        self.assertEqual(expected_return, actual_return)
