$xmlText = "<Tests>"
$xmlText += Get-Content .\*.xml
$xmlText += "</Tests>"
$TestToRegionMapping = [xml](Get-Content ..\TestToRegionMapping.xml)

$xmlData = [xml]$xmlText

#Get Unique Platforms
$Platforms = $xmlData.Tests.test.Platform  | Sort-Object | Get-Unique
Write-Host $Platforms
$Categories = $xmlData.Tests.test.Category | Sort-Object | Get-Unique
Write-Host $Categories
$Areas =$xmlData.Tests.test.Area | Sort-Object | Get-Unique
Write-Host $Areas
$Tags =$xmlData.Tests.test.Tags.Split(",") | Sort-Object | Get-Unique
Write-Host $Tags
$TestNames = $xmlData.Tests.test.TestName | Sort-Object | Get-Unique
Write-Host $TestNames


$jenkinsFile =  "platform`tcategory`tarea`tregion`n"
#Generate Jenkins File
foreach ( $platform in $Platforms )
{
    $Categories = ($xmlData.Tests.test | Where-Object { $_.Platform -eq "$platform" }).Category
    foreach ( $category in $Categories)
    {
        $Regions =$TestToRegionMapping.enabledRegions.global.Split(",")
        $Areas = ($xmlData.Tests.test | Where-Object { $_.Platform -eq "$platform" } | Where-Object { $_.Category -eq "$category" }).Area
        if ( $TestToRegionMapping.enabledRegions.Category.$category )
        {
            $Regions = ($TestToRegionMapping.enabledRegions.Category.$category).Split(",")
        }
        foreach ($area in $Areas)
        {
            if ( [string]::IsNullOrEmpty($TestToRegionMapping.enabledRegions.Category.$category))
            {
                if ($TestToRegionMapping.enabledRegions.Area.$area)
                {
                    $Regions = ($TestToRegionMapping.enabledRegions.Area.$area).Split(",")
                }
            }
            else
            {
                Write-Host "Constrained Category $category"
                $Regions = ($TestToRegionMapping.enabledRegions.Category.$category).Split(",")
                if ( $TestToRegionMapping.enabledRegions.Area.$area )
                {
                    $tempRegions = @()
                    $AreaRegions = ($TestToRegionMapping.enabledRegions.Area.$area).Split(",")
                    foreach ( $arearegion in $AreaRegions )
                    {
                        Write-Host "foreach ( $arearegion in $AreaRegions )"
                        if ( $Regions.Contains($arearegion))
                        {
                            Write-Host "if ( $Regions.Contains($arearegion))"
                            $tempRegions += $arearegion
                        }
                    }
                    if ( $tempRegions.Count -ge 1)
                    {
                        $Regions = $tempRegions
                    }
                    else
                    {
                        $Regions = "no_region_available"
                    }
                }
            }
            foreach ( $region in $Regions)
            {
                $jenkinsFile += "$platform`t$category`t$area`t$region`n"
            }
        }
        if ( $(($Areas | Get-Unique).Count) -gt 1)
        {
            foreach ( $region in $Regions)
            {
                $jenkinsFile += "$platform`t$category`tAll`t$region`n"
            }
        }
    }
    if ( $(($Categories | Get-Unique).Count) -gt 1)
    {
        foreach ( $region in $Regions)
        {
            $jenkinsFile += "$platform`tAll`tAll`t$region`n"
        }
    }
}
Set-Content -Value $jenkinsFile -Path .\jenkinsfile -Force
(Get-Content .\jenkinsfile) | Where-Object {$_.trim() -ne "" } | set-content .\jenkinsfile

$tagsFile = "tag`tregion`n"
foreach ( $tag in $Tags)
{
    $Regions =$TestToRegionMapping.enabledRegions.global.Split(",")
    if ( $tag )
    {
        if ( $TestToRegionMapping.enabledRegions.Tag.$tag )
        {
            $Regions = ($TestToRegionMapping.enabledRegions.Tag.$tag).Split(",")
        }
        foreach ( $region in $Regions)
        {
            $tagsFile += "$tag`t$region`n"
        }
    }
}
Set-Content -Value $tagsFile -Path .\tagsFile -Force
(Get-Content .\tagsFile) | Where-Object {$_.trim() -ne "" } | set-content .\tagsFile

$testnameFile = "testname`tregion`n"
foreach ( $testname in $TestNames)
{
    $Regions =$TestToRegionMapping.enabledRegions.global.Split(",")
    if ( $TestToRegionMapping.enabledRegions.TestName.$testname )
    {
        $Regions = ($TestToRegionMapping.enabledRegions.TestName.$testname).Split(",")
    }
    if ( $testname )
    {
        foreach ( $region in $Regions)
        {
            $testnameFile += "$testname`t$region`n"
        }
    }
}
Set-Content -Value $testnameFile -Path .\testnameFile -Force
(Get-Content .\testnameFile) | Where-Object {$_.trim() -ne "" } | set-content .\testnameFile



$jenkinsFile2 =  "platform`tcategory`tarea`ttestname`tregion`n"
#Generate Jenkins File
foreach ( $platform in $Platforms )
{
    $Categories = ($xmlData.Tests.test | Where-Object { $_.Platform -eq "$platform" }).Category
    foreach ( $category in $Categories)
    {
        $Regions =$TestToRegionMapping.enabledRegions.global.Split(",")
        $Areas = ($xmlData.Tests.test | Where-Object { $_.Platform -eq "$platform" } | Where-Object { $_.Category -eq "$category" }).Area
        if ( $TestToRegionMapping.enabledRegions.Category.$category )
        {
            $Regions = ($TestToRegionMapping.enabledRegions.Category.$category).Split(",")
        }
        foreach ($area in $Areas)
        {
            if ( [string]::IsNullOrEmpty($TestToRegionMapping.enabledRegions.Category.$category))
            {
                if ($TestToRegionMapping.enabledRegions.Area.$area)
                {
                    $Regions = ($TestToRegionMapping.enabledRegions.Area.$area).Split(",")
                }
            }
            else
            {
                $Regions = ($TestToRegionMapping.enabledRegions.Category.$category).Split(",")
                if ( $TestToRegionMapping.enabledRegions.Area.$area )
                {
                    $tempRegions = @()
                    $AreaRegions = ($TestToRegionMapping.enabledRegions.Area.$area).Split(",")
                    foreach ( $arearegion in $AreaRegions )
                    {
                        if ( $Regions.Contains($arearegion))
                        {
                            $tempRegions += $arearegion
                        }
                    }
                    if ( $tempRegions.Count -ge 1)
                    {
                        $Regions = $tempRegions
                    }
                    else
                    {
                        $Regions = "no_region_available"
                    }
                }
            }
            $TestNames = ($xmlData.Tests.test | Where-Object { $_.Platform -eq "$platform" } | Where-Object { $_.Category -eq "$category" } | Where-Object { $_.Area -eq "$area" } ).TestName
            foreach ( $testname in $TestNames )
            {
                $Regions =$TestToRegionMapping.enabledRegions.global.Split(",")
                if ( $TestToRegionMapping.enabledRegions.TestName.$testname )
                {
                    $Regions = ($TestToRegionMapping.enabledRegions.TestName.$testname).Split(",")
                }
                foreach ( $region in $Regions)
                {
                    #Write-Host "$platform`t$category`t$area`t$testname`t$region"
                    $jenkinsFile2 += "$platform`t$category`t$area`t$testname`t$region`n"
                }
            }
        }
    }
}
Write-Host "Setting Content"
Set-Content -Value $jenkinsFile2 -Path .\jenkinsfile2 -Force
Write-Host "Replacing whitespaces"
(Get-Content .\jenkinsfile2) | Where-Object {$_.trim() -ne "" } | set-content .\jenkinsfile2
Write-Host "Completed."
exit 0