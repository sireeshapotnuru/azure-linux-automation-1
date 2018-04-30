if ( $customSecretsFilePath )
{
	$secretsFile = $customSecretsFilePath
	Write-Host "Using provided secrets file: $($secretsFile | Split-Path -Leaf)"
}
if  ($env:Azure_Secrets_File)
{
	$secretsFile = $env:Azure_Secrets_File
	Write-Host "Using predefined secrets file: $($secretsFile | Split-Path -Leaf) in Jenkins Global Environments."
}
if ( $secretsFile -eq $null )
{
    Write-Host "ERROR: Azure Secrets file not found in Jenkins / user not provided -customSecretsFilePath" -ForegroundColor Red -BackgroundColor Black
    exit 1
}


if ( Test-Path $secretsFile)
{
	Write-Host "$($secretsFile | Split-Path -Leaf) found."
    $xmlSecrets = [xml](Get-Content $secretsFile)
    .\AddAzureRmAccountFromSecretsFile.ps1 -customSecretsFilePath $secretsFile
	$subscriptionID = $xmlSecrets.secrets.SubscriptionID
}
else
{
	Write-Host "$($secretsFile | Split-Path -Leaf) file is not added in Jenkins Global Environments OR it is not bound to 'Azure_Secrets_File' variable." -ForegroundColor Red -BackgroundColor Black
	Write-Host "Aborting." -ForegroundColor Red -BackgroundColor Black
	exit 1
}

$vmCompareFile = "Z:\Jenkins_Shared_Do_Not_Delete\userContent\shared\azure-vm-sizes.txt"
$diffFile = "Z:\Jenkins_Shared_Do_Not_Delete\userContent\shared\azure-vm-sizes-base.txt"
Write-Host "Getting regions"
Rename-Item -Path $diffFile -NewName "azure-vm-sizes-fallback.txt" -Force -ErrorAction SilentlyContinue
$allRegions = (Get-AzureRmLocation).Location
Rename-Item -Path $vmCompareFile -NewName $( Split-Path $diffFile -Leaf ) -Force -ErrorAction SilentlyContinue | Out-Null
foreach ( $region in $allRegions)
{
    try
    {
        Write-Host "Getting VM sizes from $region"
        $vmSizes = Get-AzureRmVMSize -Location $region
        foreach ( $vmSize in $vmSizes )
        {
            Add-Content -Value "$region $($vmSize.Name)" -Path $vmCompareFile -Force
        }
    }
    catch
    {
        Write-Error "Failed to fetch data from $region."
    }
}

$newVMSizes = Compare-Object -ReferenceObject (Get-Content -Path $diffFile ) -DifferenceObject (Get-Content -Path $vmCompareFile)
$newVMs = 0
$newVMsString = $null
foreach ( $newSize in $newVMSizes.InputObject )
{
    $newVMs += 1
    Write-Host "$newVMs. $newSize"
    $newVMsString += "$newSize,"
}
if ( $newVMs -eq 0)
{
    Write-Host "No New sizes today."
    Set-Content -Value "NO_NEW_VMS" -Path todaysNewVMs.txt
}
else
{
    Set-Content -Value $($newVMsString.TrimEnd(",")) -Path todaysNewVMs.txt
}
exit 0