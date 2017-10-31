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


def merge_dicts(dict1, dict2):
    """Recursively merges dict2 into dict1"""

    def merge_lists(list1, list2):
        str_list1 = [e for e in list1 if isinstance(e, str)]
        not_str_list1 = [e for e in list1 if not isinstance(e, str)]

        str_list2 = [e for e in list2 if isinstance(e, str)]
        not_str_list2 = [e for e in list2 if not isinstance(e, str)]

        result = sorted(list(set(str_list1 + str_list2)))

        if len(not_str_list1) == 0:
            if len(not_str_list2) == 0:
                return result
            else:
                return result + not_str_list2
        else:
            for i in not_str_list1:
                m = i
                for j in not_str_list2:
                    m = merge_dicts(i, j)
                result.append(m)
            return result

    if isinstance(dict1, list) and isinstance(dict2, list):
        return merge_lists(dict1, dict2)

    if not isinstance(dict1, dict) or not isinstance(dict2, dict):
        return dict1

    for k in dict2:
        if k in dict1:
            dict1[k] = merge_dicts(dict1[k], dict2[k])
        else:
            dict1[k] = dict2[k]
    return dict1
