# All Rights Reserved.
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

"""Utilities and helper functions."""

import base64
import io
import tarfile


def tar_gz_base64(dir_path):
    """Compress target directory and convert to Base64 string."""
    try:
        f = io.BytesIO()
        with tarfile.open(fileobj=f, mode='w:gz') as archive:
            archive.add(dir_path, arcname='.')

        return base64.b64encode(f.getvalue()).decode('utf-8')
    finally:
        f.close()


class Struct(dict):
    """Specialized dict where you access an item like an attribute

    >>> struct = Struct()
    >>> struct['a'] = 1
    >>> struct.b = 2
    >>> assert struct.a == 1
    >>> assert struct['b'] == 2
    """

    def __getattr__(self, name):
        try:
            return self[name]
        except KeyError:
            raise AttributeError(name)

    def __setattr__(self, name, value):
        try:
            self[name] = value
        except KeyError:
            raise AttributeError(name)
