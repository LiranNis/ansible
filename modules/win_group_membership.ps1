#!powershell
# This file is part of Ansible
#
# Copyright 2017, Liran Nisanov <lirannis@gmail.com>
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

# WANT_JSON
# POWERSHELL_COMMON

########

Function Get-Group($group_name) 
{
    $adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
    $adsi.Children | where { $_.SchemaClassName -eq 'Group' -and $_.Name -eq $group_name }
}

########

$params = Parse-Args $args

$result = @{ 
    changed = $false
}

$name = Get-AnsibleParam -obj $params -name "name" -type "str" -failifempty $true
$domain = Get-AnsibleParam -obj $params -name "domain" -type "str"
$groups = Get-AnsibleParam -obj $params -name "groups" -failifempty $true -aliases "group"
$state = Get-AnsibleParam -obj $params -name "state" -type "str" -default "present" -validateset "present","absent"

## Test vars:
#$name = "TEST.COM/TestGroup"
#$domain = "TEST.COM"
#$groups = "Administrators"
#$name = "user1"

if ($domain) {
    $member = ([ADSI]"WinNT://$domain/$name")
} else {
    $member = ([ADSI]"WinNT://$env:COMPUTERNAME/$name")
}

if ($member -eq $null) {
    Fail-Json $result "object '$name' not found"
}

If ($groups -is [System.String]) {
    [string[]]$groups = $groups.Split(",")
} elseif ($groups -isnot [System.Collections.IList]) {
    Fail-Json $result "groups must be a string or array"
}

$groups = $groups | ForEach { ([string]$_).Trim() } | Where { $_ }

try
{
    if ($null -ne $groups) {
        if ($state -eq "absent") {
            foreach ($grp in $groups) {
                #$group_obj = $adsi.Children | where { $_.SchemaClassName -eq 'Group' -and $_.Name -eq $grp }
                $group_obj = Get-Group $grp
                if ($group_obj) {
                    if (($group_obj.Members() | foreach {$_.GetType().InvokeMember("adspath", 'GetProperty', $null, $_, $null)}) -contains $member.adspath) {
                        $group_obj.Remove($member.adspath)
                        $result.changed = $true
                    }
                }
                else {
                    Fail-Json $result "group '$grp' not found"
                }
            }
        }
        elseif ($state -eq "present") {
            foreach ($grp in $groups) {
                #$group_obj = $adsi.Children | where { $_.SchemaClassName -eq 'Group' -and $_.Name -eq $grp }
                $group_obj = Get-Group $grp
                if ($group_obj) {
                    if (($group_obj.Members() | foreach {$_.GetType().InvokeMember("adspath", 'GetProperty', $null, $_, $null)}) -notcontains $member.adspath) {
                        $group_obj.Add($member.adspath)
                        $result.changed = $true
                    }
                }
                Else {
                    Fail-Json $result "group '$grp' not found"
                }
            }
        }
    }
} 
catch {
    Fail-Json $result $_.Exception.Message
}

Exit-Json $result