$win32_vol = Get-CimInstance Win32_Volume


$volumes = @()
foreach ($volume in $win32_vol)
{
   $thisvol = New-Object psobject @{
   device = $volume.DeviceID
   fstype = $volume.FileSystem
   driveletter = $volume.DriveLetter
   size_available = $volume.FreeSpace
   size_total = $volume.Capacity
   }

   $volumes += $thisvol
   $thisvol = $null
}

Set-Attr $result.ansible_facts "ansible_volumes" $volumesd
