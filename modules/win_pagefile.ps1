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

function Remove-Pagefile($path) {
    Get-WmiObject Win32_PageFileSetting | WHERE { $_.Name -eq $path } | Remove-WmiObject
}

########

$automatic = $false # Done
$drive = "C" # Add different variations
$initialSize = 0 # Done
$maximumSize = 0 # Done
$override = $true
$path = "pagefile.sys"
$fullPath = $drive + ":\" + $path
$removeAll = $false # Done
$state = "present" # Done
$systemManaged = $false # Done

if ($removeAll)
{
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\" -Name PagingFiles -Value "" -PropertyType MultiString -Force
    Get-WmiObject Win32_PageFileSetting | Remove-WmiObject
}

$computerSystem = Get-WmiObject -Class win32_computersystem -EnableAllPrivileges

if ($computerSystem.AutomaticManagedPagefile -ne $automatic) {
    $computerSystem.AutomaticManagedPagefile = $automatic
    $computerSystem.Put()
}

if ($state -eq "absent")
{
    Remove-Pagefile $fullPath
}
elseif ($state -eq "present")
{
    if ($override)
    {
        Remove-Pagefile $fullPath
    }

    if ($systemManaged)
    {
        Set-WmiInstance -Class Win32_PageFileSetting -Arguments @{name = $fullPath; InitialSize = 0; MaximumSize = 0}
    }
    else
    {
        Set-WmiInstance -Class Win32_PageFileSetting -Arguments @{name = $fullPath; InitialSize = $initialSize; MaximumSize = $maximumSize}
    }
}