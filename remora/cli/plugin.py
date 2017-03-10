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

"""OpenStackClient plugin for COE cluster lifecycle managiment."""

from osc_lib import utils
from oslo_log import log as logging

LOG = logging.getLogger(__name__)

DEFAULT_API_VERSION = '1'
API_VERSION_OPTION = 'os_coe_api_version'
API_NAME = 'coe'
API_VERSIONS = {
    '1': 'remora.v1.client.Client',
}


def make_client(instance):
    """Returns an remora client."""
    remora_client = utils.get_client_class(
        API_NAME,
        instance._api_version[API_NAME],
        API_VERSIONS)
    LOG.debug('Instantiating remora client: %s', remora_client)

    client = remora_client(session=instance.session,
                           region_name=instance.region_name,
                           interface=instance.interface,
                           verify=instance.verify,
                           cacert=instance.cacert)
    return client


def build_option_parser(parser):
    """Hook to add global options"""
    parser.add_argument(
        '--os-coe-api-version',
        metavar='<coe-api-version>',
        default=utils.env(
            'OS_COE_API_VERSION',
            default=DEFAULT_API_VERSION),
        help=('Queues API version, default=' +
              DEFAULT_API_VERSION +
              ' (Env: OS_COE_API_VERSION)'))
    return parser
