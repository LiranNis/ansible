$Automatic = false # Done
$Drive = "C" # Add different variations
$InitialSize = 0
$MaximumSize = 0 
$Path = $Drive + ":\pagefile.sys" # Done
$RemoveAll = false # Done
$State = "present" # Done
$SystemManaged = false

if ($RemoveAll)
{
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\" -Name PagingFiles -Value "" -PropertyType MultiString -Force
    Get-WmiObject Win32_PageFileSetting | Remove-WmiObject
}

if ($Automatic)
{
    wmic computersystem set AutomaticManagedPageFile=TRUE
}
else
{
    wmic computersystem set AutomaticManagedPageFile=FALSE

    if ($State -eq "absent")
    {
        Get-WmiObject Win32_PageFileSetting | WHERE Name -eq $Path | Remove-WmiObject
    }

    if ($State -eq "present")
    {
        if ($SystemManaged)
        {

        }
        else
        {
            Set-WmiInstance -Class Win32_PageFileSetting -Arguments @{name=$Path; InitialSize = $InitialSize; MaximumSize = $MaximumSize}
        }
    }

    # Windows Server 2012


    # Windows Server 2008
#    Set-WmiInstance -Class Win32_PageFileSetting -Arguments @{name="C:\pagefile.sys"; InitialSize = 20; MaximumSize = 20 }
}

