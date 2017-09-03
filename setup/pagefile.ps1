$win32_pfs = Get-WmiObject Win32_PageFileSetting
$pagefiles = @()

foreach ($currentPagefile in $win32_pfs) {
    $currentPagefileObject = @{
        name = $currentPagefile.Name
        initial_size = $currentPagefile.InitialSize
        maximum_size = $currentPagefile.MaximumSize
        caption = $currentPagefile.Caption
        description = $currentPagefile.Description
    }
    $pagefiles += $currentPagefileObject
}

# Add to ansible facts
ansible_pagefiles = $pagefiles
