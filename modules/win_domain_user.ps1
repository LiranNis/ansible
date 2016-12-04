#!powershell
# This file is part of Ansible
#
# Copyright 2016, LiranNis <lirannis@gmail.com>
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
#. "C:\Users\liran.test\Desktop\powershell.ps1"

$params = Parse-Args $args

$result = New-Object PSObject;
Set-Attr $result "changed" $false;

$name = Get-Attr $params "name" -failifempty $true
$domain = Get-Attr $params "domain" $null

#$name = "TEST.COM/TestGroup"
#$domain = "TEST.COM"

$adsi = [ADSI]"WinNT://$env:COMPUTERNAME"

if ($domain) {
    $domain_obj = ([ADSI]"WinNT://$domain/$name")
}
else {
    $name = $name.Replace('\','/')
    $domain_obj = ([ADSI]"WinNT://$name")
}



#$groups = Get-Attr $params "groups" -failifempty $true
$groups="Administrators"
If ($groups -is [System.String]) {
    [string[]]$groups = $groups.Split(",")
}
ElseIf ($groups -isnot [System.Collections.IList]) {
    Fail-Json $result "groups must be a string or array"
}
$groups = $groups | ForEach { ([string]$_).Trim() } | Where { $_ }

$state = Get-Attr $params "state" "absent"
$state = $state.ToString().ToLower()
If (($state -ne "present") -and ($state -ne "absent")) {
    Fail-Json $result "state is '$state'; must be 'present' or 'absent'"
}

try
{
    If ($null -ne $groups) {
        If ($state -eq "absent") {
            ForEach ($grp in $groups) {
                $group_obj = $adsi.Children | where { $_.SchemaClassName -eq 'Group' -and $_.Name -eq $grp }
                If ($group_obj) {
                    if (($group_obj.Members() | foreach {$_.GetType().InvokeMember("GUID", 'GetProperty', $null, $_, $null)}) -contains $domain_obj.Guid) {
                        $group_obj.Remove($domain_obj.Path)
                        $result.changed = $true
                    }
                }
                Else {
                    Fail-Json $result "group '$grp' not found"
                }
            }
        }
        ElseIf ($state -eq "present") {
            ForEach ($grp in $groups) {
                $group_obj = $adsi.Children | where { $_.SchemaClassName -eq 'Group' -and $_.Name -eq $grp }
                If ($group_obj) {
                    if (($group_obj.Members() | foreach {$_.GetType().InvokeMember("GUID", 'GetProperty', $null, $_, $null)}) -notcontains $domain_obj.Guid) {
                        $group_obj.Add($domain_obj.Path)
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