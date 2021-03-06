# This is not ansible win_group_membership original module! It is another implementation that was written before the merge.
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

Function Get-ComputerADsPath
{
    $adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
    $adsi.adspath
}

########

$params = Parse-Args $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name '_ansible_check_mode' -type 'bool' -default $false

$name = Get-AnsibleParam -obj $params -name "name" -type "str" -failifempty $true
$domain = Get-AnsibleParam -obj $params -name "domain" -type "str"
$groups = Get-AnsibleParam -obj $params -name "groups" -failifempty $true -aliases @("group")
$state = Get-AnsibleParam -obj $params -name "state" -type "str" -default "present" -validateset "present","absent"

$result = @{ 
    changed = $false
}

if ($domain) {
    $domain = $domain.Split('.')[0]
    $path = "WinNT://$domain/$name"
} else {
    try {
        $path = "$(Get-ComputerADsPath)/$name"
    } catch {
        Fail-Json $result "Can not retrieve computer adspath"
    }
}

if (-not [ADSI]::Exists($path)) {
    Fail-Json $result "Object $name not found"
}

If ($groups -is [System.String]) {
    [string[]]$groups = $groups.Split(",")
} elseif ($groups -isnot [System.Collections.IList]) {
    Fail-Json $result "groups must be a string or array"
}

$groups = $groups | ForEach { ([string]$_).Trim() } | Where { $_ }

if ($null -ne $groups) {
    if ($state -eq "absent") {
        foreach ($grp in $groups) {
            try {
                $group_obj = Get-Group $grp
            } catch {
                Fail-Json $result "Failed to get group $grp - $($_.Exception.Message)"
            }
            if ($group_obj) {
                if ($group_obj.isMember($path)) {
                    if (-not $check_mode) {
                        try {
                            $group_obj.Remove($path)
                        } catch {
                            Fail-Json $result "Failed to remove object $name - $($_.Exception.Message)"
                        }
                    }
                    $result.changed = $true
                }
            }
            else {
                Fail-Json $result "Group '$grp' not found"
            }
        }
    }
    elseif ($state -eq "present") {
        foreach ($grp in $groups) {
            try {
                $group_obj = Get-Group $grp
            } catch {
                Fail-Json $result "Failed to get group $grp - $($_.Exception.Message)"
            }
            if ($group_obj) {
                if (-not $group_obj.isMember($path)) {
                    if (-not $check_mode) {
                        try {
                            $group_obj.Add($path)
                        } catch {
                            Fail-Json $result "Failed to add member $name - $($_.Exception.Message)"
                        }
                    }
                    $result.changed = $true
                }
            }
            else {
                Fail-Json $result "Group '$grp' not found"
            }
        }
    }
}

Exit-Json $result
