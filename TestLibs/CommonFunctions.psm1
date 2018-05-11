function LogVerbose () 
{
    param
    (
        $text
    )
    $text = $text.Replace('"','`"')
    $now = [Datetime]::Now.ToUniversalTime().ToString("MM/dd/yyyy HH:mm:ss")
    Invoke-Expression -Command "Write-Verbose `"$now : $text`" $VerboseCommand"    
}
function LogError () 
{
    param
    (
        $text
    )
    $text = $text.Replace('"','`"')
    $now = [Datetime]::Now.ToUniversalTime().ToString("MM/dd/yyyy HH:mm:ss")
    Invoke-Expression -Command "Write-Error `"$now : $text`""    
}

function LogMsg()
{
    param
    (
        $text
    )
    $text = $text.Replace('"','`"')
    $now = [Datetime]::Now.ToUniversalTime().ToString("MM/dd/yyyy HH:mm:ss")
    Invoke-Expression -Command "Write-Host `"$now : $text`""  
}

Function ValiateXMLs( [string]$ParentFolder )
{
    LogMsg "Validating XML Files from $ParentFolder folder recursively..."
    LogVerbose "Get-ChildItem `"$ParentFolder\*.xml`" -Recurse..."
    $allXmls = Get-ChildItem "$ParentFolder\*.xml" -Recurse
    $xmlErrorFiles = @()
    foreach ($file in $allXmls)
    {
        try
        {
            $TempXml = [xml](Get-Content $file.FullName)
            LogVerbose -text "$($file.FullName) validation successful."
            
        }
        catch
        {
            LogError -text "$($file.FullName) validation failed."
            $xmlErrorFiles += $file.FullName
        }
    }
    if ( $xmlErrorFiles.Count -gt 0 )
    {
        $xmlErrorFiles | ForEach-Object -Process {LogMsg $_}
        Throw "Please fix above ($($xmlErrorFiles.Count)) XML files."
    }
}