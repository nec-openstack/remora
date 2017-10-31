# -*- encoding: utf-8 -*-
# Copyright (c) 2016 b<>com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import unicode_literals

from oslo_log import log
from stevedore import driver as drivermanager
from stevedore import extension as extensionmanager

from remora.common import exception
from remora.common.loader import base
from remora.common import utils

LOG = log.getLogger(__name__)


class DefaultLoader(base.BaseLoader):

    def __init__(self, namespace):
        """Entry point loader for Remora using Stevedore

        :param namespace: namespace of the entry point(s) to load or list
        :type namespace: str
        """
        super(DefaultLoader, self).__init__()
        self.namespace = namespace

    def load(self, name, **kwargs):
        try:
            LOG.debug("Loading in namespace %s => %s ", self.namespace, name)
            driver_manager = drivermanager.DriverManager(
                namespace=self.namespace,
                name=name,
                invoke_on_load=False,
            )

            driver_cls = driver_manager.driver
            driver = driver_cls(**kwargs)
        except Exception as exc:
            LOG.exception(exc)
            raise exception.LoadingError(name=name)

        return driver

    def get_entry_name(self, name):
        return ".".join([self.namespace, name])

    def list_available(self):
        extension_manager = extensionmanager.ExtensionManager(
            namespace=self.namespace)
        return {ext.name: ext.plugin for ext in extension_manager.extensions}
