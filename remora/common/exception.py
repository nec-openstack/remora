# -*- encoding: utf-8 -*-
# Copyright (c) 2015 b<>com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Remora base exception handling.

Includes decorator for re-raising remora-type exceptions.

SHOULD include dedicated exception logging.

"""

import logging
import six

from remora.i18n import _, _LE

LOG = logging.getLogger(__name__)


class RemoraException(Exception):
    """Base Remora Exception

    To correctly use this class, inherit from it and define
    a 'msg_fmt' property. That msg_fmt will get printf'd
    with the keyword arguments provided to the constructor.

    """
    msg_fmt = _("An unknown exception occurred")
    safe = False

    def __init__(self, message=None, **kwargs):
        self.kwargs = kwargs

        if not message:
            try:
                message = self.msg_fmt % kwargs
            except Exception:
                # kwargs doesn't match a variable in msg_fmt
                # log the issue and the kwargs
                LOG.exception(_LE('Exception in string format operation'))
                for name, value in kwargs.items():
                    LOG.error(_LE("%(name)s: %(value)s"),
                              {'name': name, 'value': value})

                raise

        super(RemoraException, self).__init__(message)

    def __str__(self):
        """Encode to utf-8 then wsme api can consume it as well"""
        if not six.PY3:
            return six.text_type(self.args[0]).encode('utf-8')
        else:
            return self.args[0]

    def __unicode__(self):
        return six.text_type(self.args[0])

    def format_message(self):
        if self.__class__.__name__.endswith('_Remote'):
            return self.args[0]
        else:
            return six.text_type(self)


class LoadingError(RemoraException):
    msg_fmt = _("Error loading plugin '%(name)s'")


class AssetsDirNotSpecified(RemoraException):
    msg_fmt = _("Error assets_dir is not configured: spec.local.assets_dir")
