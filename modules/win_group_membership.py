#!/usr/bin/python
# -*- coding: utf-8 -*-

# (c) 2017, Liran Nisanov <lirannis@chathamfinancial.com>
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
version_added: "2.3"
short_description: Add or remove local or domain object to a local group
description:
    - Add or remove local or domain object to a local group
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
      - The groups. 
      - can contain multiple groups comma separated.
    required: true
    aliases: [ group ]
  state:
    description:
      - State of the user in the group: present, absent.
    choices:
      - present
      - absent
    default: present
notes:
author: "Liran Nisanov (@LiranNis)"
'''

EXAMPLES = r'''
- name: Create registry path MyCompany
  win_regedit:
    path: HKCU:\Software\MyCompany
- name: Add or update registry path MyCompany, with entry 'hello', and containing 'world'
  win_regedit:
    path: HKCU:\Software\MyCompany
    name: hello
    data: world
- name: Add or update registry path MyCompany, with entry 'hello', and containing 1337
  win_regedit:
    path: HKCU:\Software\MyCompany
    name: hello
    data: 1337
    type: dword
- name: Add or update registry path MyCompany, with entry 'hello', and containing binary data in hex-string format
  win_regedit:
    path: HKCU:\Software\MyCompany
    name: hello
    data: hex:be,ef,be,ef,be,ef,be,ef,be,ef
    type: binary
- name: Add or update registry path MyCompany, with entry 'hello', and containing binary data in yaml format
  win_regedit:
    path: HKCU:\Software\MyCompany
    name: hello
    data: [0xbe,0xef,0xbe,0xef,0xbe,0xef,0xbe,0xef,0xbe,0xef]
    type: binary
- name: Disable keyboard layout hotkey for all users (changes existing)
  win_regedit:
    path: HKU:\.DEFAULT\Keyboard Layout\Toggle
    name: Layout Hotkey
    data: 3
    type: dword
- name: Disable language hotkey for current users (adds new)
  win_regedit:
    path: HKCU:\Keyboard Layout\Toggle
    name: Language Hotkey
    data: 3
    type: dword
- name: Remove registry path MyCompany (including all entries it contains)
  win_regedit:
    path: HKCU:\Software\MyCompany
    state: absent
- name: Remove entry 'hello' from registry path MyCompany
  win_regedit:
    path: HKCU:\Software\MyCompany
    name: hello
    state: absent
'''

RETURN = r'''
data_changed:
    description: whether this invocation changed the data in the registry value
    returned: success
    type: boolean
    sample: False
data_type_changed:
    description: whether this invocation changed the datatype of the registry value
    returned: success
    type: boolean
    sample: True
'''
