#!/usr/bin/python
# -*- coding: utf-8 -*-

# (c) 2017, Liran Nisanov <lirannis@gmail.com>
#
# This file is part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

# this is a windows documentation stub.  actual code lives in the .ps1
# file of the same name

ANSIBLE_METADATA = {'metadata_version': '1.0',
                    'status': ['preview'],
                    'supported_by': 'community'}


DOCUMENTATION = r'''
---
module: win_group_membership
version_added: "2.4"
short_description: Add or remove local or domain object from a local group
description:
    - Add or remove local or domain object from a local group.
options:
  name:
    description:
      - The name of the object.
    required: true
  domain:
    description:
      - The domain of the object.
      - Leave empty for local object.
  groups:
    description:
      - The groups to add the object, can contain multiple groups comma separated or list of groups.
    required: true
    aliases: 
      - group
  state:
    description:
      - State of the user in the group.
    choices:
      - present
      - absent
    default: present
notes:
- Adding non-existing user to a group or a user to non-existing group will cause this module to fail.
author: 
- Liran Nisanov (@LiranNis)
'''

EXAMPLES = r'''
- name: Add local user User1 to Administrators group
  win_group_membership:
    name: User1
    group: Administrators
    state: present

 - name: Remove local user User1 from Administrators group
   win_group_membership:
     name: User1
     group: administrators
     state: absent

 - name: Add domain user User to local Remote Desktop Users group
   win_group_membership:
     name: User
     domain: AWESOME.DOMAIN
     group: Remote Desktop Users
     state: present

- name: Remove the domain user USER from the group
  win_group_membership:
    name: User
    domain: AWESOME.DOMAIN
    group: Remote Desktop Users
    state: absent

- name: Add domain group Support to multiple groups
  win_group_membership:
    name: Support
    domain: awesome
    groups:
      - Remote Desktop Users
      - Remote Management Users
    state: present

- name: Remove domain group Support from multiple groups
  win_group_membership:
    name: Support
    domain: awesome.domain
    groups:
      - Remote Desktop Users
      - Remote Management Users
    state: absent
'''

RETURN = r'''
'''
