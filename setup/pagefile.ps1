 $result.pagefiles = @()

try {
        $pagefiles = Get-Pagefile $fullPath
} catch {
        Fail-Json $result "Failed to query specific pagefile $($_.Exception.Message)"
}


# Get all pagefiles
foreach ($currentPagefile in $pagefiles) {
    $currentPagefileObject = @{
        name = $currentPagefile.Name
        initial_size = $currentPagefile.InitialSize
        maximum_size = $currentPagefile.MaximumSize
        caption = $currentPagefile.Caption
        description = $currentPagefile.Description
    }
    $result.pagefiles += $currentPagefileObject
}
