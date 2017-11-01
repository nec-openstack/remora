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

import logging

from remora import constants
from remora.fab import helpers


LOG = logging.getLogger(__name__)


def _merge_config(user_config):
    """Merge default.yaml and user inputed config"""
    # FIXME(yuanying): use improved merge_dicts
    merged_config = helpers.merge_dicts(
        user_config,
        constants.DEFAULT_CONFIG
    )
    return merged_config


def _extract_nodes_from_node_groups(node_groups, default_spec={}):
    node_list = {}
    for _, node_group in node_groups.items():
        node_spec = node_group.get('spec', {})
        # FIXME(yuanying): use improved merge_dicts
        spec = helpers.merge_dicts(node_spec, default_spec)
        nodes = node_group.get('nodes', [])
        for node in nodes:
            if node in node_list.keys():
                LOG.warn("node: {} is already defined".format(node))
            else:
                node_list[node] = spec
    return node_list


def normarize(user_config):
    """Return nodes dict

    ex:
        {
            'node_ip_or_name01': {
                'kubernetes': {},
                'etcd': {},
            },
            'node_ip_or_name2': {
                'kubernetes': {},
                'etcd': {},
            }
        }
    """
    user_config = _merge_config(user_config)
    default_spec = user_config['spec']
    node_groups = user_config['nodeGroups']
    nodes = _extract_nodes_from_node_groups(node_groups, default_spec)

    return nodes


def filter(nodes, labels=[]):
    """Filter nodes which matches labels"""
    labels = set(labels)
    filterd_nodes = {}
    for k, spec in nodes.items():
        node_labels = set(spec.get('labels', []))
        matched_labels = labels & node_labels
        if matched_labels == labels:
            filterd_nodes[k] = spec
    return filterd_nodes


def etcd_servers(nodes):
    return filter(nodes, ['node-role.remora/etcd'])


def master_nodes(nodes):
    return filter(nodes, ['node-role.kubernetes.io/master'])


def calculated_nodes(user_config):
    """
    Return nodes dict which contains calculated values
    such as etcd server list
    """
    return normarize(user_config)
