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

from cliff import command
from oslo_log import log as logging
import yaml

from remora.cli import utils
# from remora.cluster import cluster


class CreateCluster(command.Command):
    """Create a coe cluster"""

    log = logging.getLogger(__name__ + ".CreateCluster")

    def get_parser(self, prog_name):
        parser = super(CreateCluster, self).get_parser(prog_name)

        return parser

    @utils.global_options
    def take_action(self, parsed_args, global_options):
        with open(global_options.cluster_config) as f:
            params = yaml.load(f)
        print(params)

        return ""
