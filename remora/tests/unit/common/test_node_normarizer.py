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

import copy
import os

from remora.common import node_normalizer
from remora import constants
import remora.tests.unit.base as base


class TestMergeConfig(base.TestCase):

    def test_return_default_yaml(self):
        self.assertEqual(
            constants.DEFAULT_CONFIG,
            node_normalizer._merge_config({})
        )

    def test_return_merged_config(self):
        input_config = {"spec": {"hoge": "fugafuga"}}
        expected = copy.deepcopy(constants.DEFAULT_CONFIG)
        expected['spec']['hoge'] = 'fugafuga'

        self.assertEqual(
            expected,
            node_normalizer._merge_config(input_config)
        )


class TestExtractNodesFromNodeGroups(base.TestCase):

    def test_dict_contains_node_name_as_keys(self):
        node_groups = {
            'master': {
                'nodes': ["a", "b"]
            },
            'worker': {
                'nodes': ["c", "d"]
            }
        }
        expected = set(["a", "b", "c", "d"])

        output = node_normalizer._extract_nodes_from_node_groups(node_groups)
        self.assertEqual(
            expected,
            set(output.keys())
        )

    def test_dict_contains_node_groups_spec(self):
        expected_spec = { 'expected': 'hoge' }
        node_groups = {
            'master': {
                'spec': expected_spec,
                'nodes': ["a", "b"]
            }
        }

        output = node_normalizer._extract_nodes_from_node_groups(node_groups)
        for v in output.values():
            self.assertEqual(expected_spec, v)

    def test_dict_contains_default_spec(self):
        default_spec = { 'default': 'spec' }
        node_spec = { 'node': 'spec' }
        expected_spec = {
            'default': 'spec',
            'node': 'spec'
        }
        node_groups = {
            'master': {
                'spec': node_spec,
                'nodes': ["a", "b"]
            }
        }
        output = node_normalizer._extract_nodes_from_node_groups(
            node_groups,
            default_spec
        )
        for v in output.values():
            self.assertEqual(expected_spec, v)


class TestFilter(base.TestCase):

    def filter_master_nodes(self):
        nodes = {
            'a': {
                'labels': ['node-role.kubernetes.io/master', 'zzzz=ssss']
            },
            'b': {
                'labels': ['ccc=ddd']
            }
        }
        output = node_normalizer.filter(
            nodes,
            ['node-role.kubernetes.io/master']
        )
        self.assertEqual(output.keys(), ['a'])

    def filter_master_etcd_nodes(self):
        ma = ['node-role.kubernetes.io/master', 'node-role.remora/etcd']
        m  = ['node-role.kubernetes.io/master']
        a  = ['node-role.remora/etcd']
        x  = ['ccc']
        nodes = {
            'a': {
                'labels': ['aaa', *ma]
            },
            'b': {
                'labels': m
            },
            'd': {
                'labels': a
            },
            'e': {
                'labels': x
            },
        }
        output = node_normalizer.filter(
            nodes,
            ma
        )
        self.assertEqual(output.keys(), ['a'])
