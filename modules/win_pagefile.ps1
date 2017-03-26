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

Function Remove-Pagefile($path) 
{
    Get-WmiObject Win32_PageFileSetting | WHERE { $_.Name -eq $path } | Remove-WmiObject
}

########

$params = Parse-Args $args;

$result = @{ 
    changed = $false
}

#$automatic = $false # Done
#$drive = "C" # Add different variations
#$initialSize = 0 # Done
#$maximumSize = 0 # Done
#$override = $true
#$fullPath = $drive + ":\pagefile.sys"
#$removeAll = $false # Done
#$state = "present" # Done
#$systemManaged = $false # Done

$automatic = Get-AnsibleParam -obj $params -name "automatic" -type "bool"
$drive = Get-AnsibleParam -obj $params -name "drive" -type "str"
$fullPath = $drive + ":\pagefile.sys"
$initialSize = Get-AnsibleParam -obj $params -name "initial_size" -type "int"
$maximumSize = Get-AnsibleParam -obj $params -name "maximum_size" -type "int"
$override =  Get-AnsibleParam -obj $params -name "override" -type "bool" -default $true
$removeAll = Get-AnsibleParam -obj $params -name "remove_all" -type "bool" -default $false
$state = Get-AnsibleParam -obj $params -name "state" -type "str" -default "query" -validateset "present","absent","query"
$systemManaged = Get-AnsibleParam -obj $params -name "system_managed" -type "bool" -default $false

if ($removeAll) {
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\" -Name PagingFiles -Value "" -PropertyType MultiString -Force
    Get-WmiObject Win32_PageFileSetting | Remove-WmiObject
}

if ($automatic -ne $null) {
    $computerSystem = Get-WmiObject -Class win32_computersystem -EnableAllPrivileges
    
    if ($computerSystem.AutomaticManagedPagefile -ne $automatic) {
        $computerSystem.AutomaticManagedPagefile = $automatic
        $computerSystem.Put()
    }
}

if ($state -eq "absent") {
    Remove-Pagefile $fullPath
} elseif ($state -eq "present") {

    if ($override) {
        Remove-Pagefile $fullPath
    }

    if ((Get-WmiObject Win32_PageFileSetting | WHERE { $_.Name -eq $path }) -eq $null) {
        if ($systemManaged) {
            Set-WmiInstance -Class Win32_PageFileSetting -Arguments @{name = $fullPath; InitialSize = 0; MaximumSize = 0}
        } else {
            Set-WmiInstance -Class Win32_PageFileSetting -Arguments @{name = $fullPath; InitialSize = $initialSize; MaximumSize = $maximumSize}
        }
        $result.changed = true
    }

} elseif ($state -eq "query") {
    $result.pagefiles = Get-WmiObject Win32_PageFileSetting
    $result.automatic_managed_pagefiles = (Get-WmiObject -Class win32_computersystem).AutomaticManagedPagefile
}
Exit-Json $result
