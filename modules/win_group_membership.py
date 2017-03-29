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
module: win_pagefile
version_added: "2.3"
short_description: Query or change pagefile configuration
description:
    - Query current pagefiles
    - Enable/Disable automatic managed pagefile
    - Create new or override pagefile
options:
  drive:
    description:
      - The drive of the pagefile.
    required: false
  initial_size:
    description:
      - The initial size of the pagefile.
  maximum_size:
    description:
      - The maximum size of the pagefile.
  override:
    description:
      - Override the current pagefile on the drive.
    choices:
      - true
      - false
    default: true
  system_managed:
    description:
      - Configures current pagefile to be managed by the system.
    choices:
      - true
      - false
    default: false
  automatic:
    description:
      - Configures automatic managed pagefile for the entire system.
    choices:
      - true
      - false
  remove_all:
    description:
      - Remove all pagefiles in the system, not including automatic managed.
    choices:
      - true
      - false
    default: false
  state:
    description:
      - State of the pagefile: present, absent, query.
    choices:
      - present
      - absent
      - query
    default: present
notes:
- There is difference between automatic managed pagefiles that configured once for the entire system and system managed pagefile that configured per pagefile.
- InitialSize 0 and MaximumSize 0 means the pagefile is managed by the system.
- "Value out of range" exception may be caused by several different issues, two common problems:
  - No such drive
  - Pagefile size is too small
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
