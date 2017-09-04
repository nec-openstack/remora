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

import glob
import os
import time
import yaml

from fabric.api import env
from fabric.api import run
from fabric.api import task


__fabric_lib_dir = os.path.abspath(os.path.dirname(__file__))
__fabric_dir = os.path.join(__fabric_lib_dir, '..', '..')
__fabric_dir = os.path.abspath(__fabric_dir)
remora_scripts_dir = os.path.join(__fabric_dir, 'remora', 'scripts')
default_configs = os.path.join(__fabric_lib_dir, 'default.yaml')
configs = os.path.join(__fabric_dir, 'configs', '*.yaml')


def remote_temp_dir(target):
    return os.path.join(env.temp_dir, target)


def recreate_remote_temp_dir(target):
    temp_path = remote_temp_dir(target)
    run("rm -rf {0}".format(temp_path))
    run("mkdir -p {0}".format(temp_path))


def merge_dicts(dict1, dict2):
    """ Recursively merges dict2 into dict1 """
    if not isinstance(dict1, dict) or not isinstance(dict2, dict):
        return dict1
    for k in dict2:
        if k in dict1:
            dict1[k] = merge_dicts(dict1[k], dict2[k])
        else:
            dict1[k] = dict2[k]
    return dict1


def construct_env(env_data, default_env_data=None):
    if not default_env_data:
        default_env_data = yaml.safe_load(open(default_configs).read())

    env_data = merge_dicts(env_data, default_env_data)
    env.update(env_data)
    roledefs = env_data.get('roledefs', None)
    if roledefs:
        hosts = set()
        for v in roledefs.values():
            hosts |= set(v)

        env.hosts = list(hosts)


def create_env_tasks(namespace):
    default_env_data = yaml.safe_load(open(default_configs).read())
    for config in glob.glob(configs):
        env_data = yaml.safe_load(open(config).read())
        stage = os.path.splitext(os.path.basename(config))[0]
        create_env_task(stage, env_data, namespace)


def create_env_task(env_name, env_dict, namespace):
    def env_task():
        env.stage = env_name
        construct_env(env_dict)

    env_task.__doc__ = u'''Set environment for {0}'''.format(env_name)

    wrapper = task(name=env_name)
    rand = '%d' % (time.time() * 100000)
    namespace['task_%s_%s' % (env_name, rand)] = wrapper(env_task)
