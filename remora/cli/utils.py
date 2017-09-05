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

import os
import functools
import yaml

from fabric.api import env

from remora.fab import helpers


def fabric_env(func):
    @functools.wraps(func)
    def wrapper(self, parsed_args):
        cluster_config = self.app.options.cluster_config
        if not cluster_config:
            self.log.error("Cluster Config is not specified")
        if not os.path.exists(cluster_config):
            self.log.error("Cluster Config is not exist: {}".format(
                cluster_config))

        with open(self.app.options.cluster_config) as f:
            params = yaml.load(f)
            env.stage = 'remora'
            helpers.construct_env(params)
        return func(self, parsed_args)

    return wrapper
