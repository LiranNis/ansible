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
    default: query
notes:
- There is difference between automatic managed pagefiles that configured once for the entire system and system managed pagefile that configured per pagefile.
- InitialSize 0 and MaximumSize 0 means the pagefile is managed by the system.
- "Value out of range" exception may be caused by several different issues, two common problems:
  - No such drive.
  - Pagefile size is too small.
- Setting a pagefile when automatic managed pagefile is on will disable it.
author: "Liran Nisanov (@LiranNis)"
'''

EXAMPLES = r'''
- name: Query all current pagefiles
  win_pagefile:
- name: Query C pagefile
  win_pagefile:
    drive=c

- name: Set C pagefile, dont override if exists
  win_pagefile:
    drive=C
    iשnitial_size=1024
    maximum_size=1024
    override=false
    state=present
- name: Set C pagefile, override if exists
  win_pagefile:
    drive=C
    initial_size=1024
    maximum_size=1024
    state=present

- name: Remove C pagefile
  win_pagefile:
    drive=c
    state=absent

- name: Remove all current pagefiles, enable automatic managed pagefile and query at the end.
  win_pagefile:
    remove_all=true
    automatic=true

- name: Remove all pagefiles disable automatic managed pagefile and set C pagefile
  win_pagefile:
    drive=c
    initial_size=2048
    maximum_size=2048
    remove_all=true
    automatic=false
    state=present
- name: Set D pagefile, override if exists
  win_pagefile:
    drive=d
    initial_size=1024
    maximum_size=1024
    state=present
'''

RETURN = r'''
automatic:
    description: whether the pagefiles is automatically managed
    type: boolean
    sample: true
pagefiles:
    description: Pagefiles on the system (only when state is query)
    type: hash
'''
