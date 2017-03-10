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
#

"""Command-line interface to the Remora APIs"""
import copy
import os
import sys

from cliff import app
from cliff import commandmanager
from keystoneauth1 import loading

import remora
from remora.cli.v1 import cluster
from remora.common import config
from remora.v1 import client


class RemoraCommandManager(commandmanager.CommandManager):
    SHELL_COMMANDS = {
        "cluster create": cluster.CreateCluster,
    }

    def load_commands(self, namespace):
        for name, command_class in self.SHELL_COMMANDS.items():
            self.add_command(name, command_class)


class RemoraShell(app.App):

    def __init__(self):
        super(RemoraShell, self).__init__(
            description='Remora command line client',
            version=remora.__version__,
            command_manager=RemoraCommandManager(None),
            deferred_help=True,
        )
        self._client = None

    def build_option_parser(self, description, version):
        """Return an argparse option parser for this application.

        Subclasses may override this method to extend
        the parser with more global options.

        :param description: full description of the application
        :paramtype description: str
        :param version: version number for the application
        :paramtype version: str
        """
        parser = super(RemoraShell, self).build_option_parser(
            description,
            version,
            argparse_kwargs={'allow_abbrev': False})

        loading.register_session_argparse_arguments(parser=parser)
        loading.register_auth_argparse_arguments(
            parser=parser, argv=sys.argv, default="v3password")

        parser.add_argument(
            '--os-interface',
            metavar='<name>',
            default=os.environ.get('OS_INTERFACE', 'public'),
            help='API Interface to use [public, internal, admin]')

        parser.add_argument(
            '--os-region-name',
            metavar='<name>',
            default=os.environ.get('OS_REGION_NAME', None),
            help='Region of the cloud to use')
        # adapter.register_adapter_argparse_arguments(
        #     parser=parser, service_type="coe")
        # adapter.register_service_adapter_argparse_arguments(
        #     parser=parser, service_type="coe")

        return parser

    @property
    def client(self):
        # NOTE(sileht): we lazy load the client to not
        # load/connect auth stuffs
        if self._client is None:
            auth_plugin = loading.load_auth_from_argparse_arguments(
                self.options)
            session = loading.load_session_from_argparse_arguments(
                self.options, auth=auth_plugin)

            # Openstck style endpoint
            kwargs = dict(
                session=session,
                interface=self.options.os_interface,
                region_name=self.options.os_region_name,
                verify=not self.options.insecure,
                cacert=self.options.os_cacert,
            )
            self._client = client.Client(**kwargs)
        return self._client


def main(args=None):
    if args is None:
        args = sys.argv[1:]
    # FIXME(yuanying)
    config.init([])
    return RemoraShell().run(args)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
