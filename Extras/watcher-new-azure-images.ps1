<#
.SYNOPSIS
  This script fetches kernel boot time and WALA provision.

.DESCRIPTION
  This script fetches kernel boot time and WALA provision time by -
    1. Downloading dmesg and waagent.log files from VM.
    2. Parsing the log files to calculate the data.

.PARAMETER -DeploymentTime
    Type: integer
    Required: Yes.

.PARAMETER -allVMData
    Type: PSObject
    Required: Yes.

.PARAMETER -customSecretsFilePath
    Type: string
    Required: Optinal.

.INPUTS
    AzureSecrets.xml file. If you are running this script in Jenkins, then make sure to add a secret file with ID: Azure_Secrets_File
    If you are running the file locally, then pass secrets file path to -customSecretsFilePath parameter.

.NOTES
    Version:        1.0
    Author:         Shital Savekar <v-shisav@microsoft.com>
    Creation Date:  14th December 2017
    Purpose/Change: Initial script development

.EXAMPLE
    .\watcher-monitor-new-images.ps1 -customSecretsFilePath .\AzureSecrets.xml
#>

param
(
    $DeploymentTime,
    $allVMData,
	[string]$customSecretsFilePath=$null
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
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
    #.\AddAzureRmAccountFromSecretsFile.ps1 -customSecretsFilePath $secretsFile
	$subscriptionID = $xmlSecrets.secrets.SubscriptionID
}
else
{
	Write-Host "$($secretsFile | Split-Path -Leaf) file is not added in Jenkins Global Environments OR it is not bound to 'Azure_Secrets_File' variable." -ForegroundColor Red -BackgroundColor Black
	Write-Host "Aborting." -ForegroundColor Red -BackgroundColor Black
	exit 1
}

if ( Test-Path $secretsFile )
{
	Write-Host "$($secretsFile | Split-Path -Leaf) found."
	Write-Host "---------------------------------"
	$xmlSecrets = [xml](Get-Content $secretsFile)

    $SubscriptionID = $xmlSecrets.secrets.SubscriptionID
    $SubscriptionName = $xmlSecrets.secrets.SubscriptionName
    $dataSource = $xmlSecrets.secrets.DatabaseServer
    $dbuser = $xmlSecrets.secrets.DatabaseUser
    $dbpassword = $xmlSecrets.secrets.DatabasePassword
    $database = $xmlSecrets.secrets.DatabaseName
    $dataTableName = "LinuxAzureDeploymentAndBootData"
    $storageAccountName = $xmlSecrets.secrets.bootPerfLogsStorageAccount
    $storageAccountKey = $xmlSecrets.secrets.bootPerfLogsStorageAccountKey

}
else
{
	Write-Host "$($secretsFile | Spilt-Path -Leaf) file is not added in Jenkins Global Environments OR it is not bound to 'Azure_Secrets_File' variable."
	Write-Host "If you are using local secret file, then make sure file path is correct."
	Write-Host "Aborting."
	exit 1
}

#---------------------------------------------------------[Script Start]--------------------------------------------------------

$allPublishers = Get-AzureRmVMImagePublisher -Location westus2
Set-Content -Value $null -Path .\temp\watcher-images.txt
foreach ($publisher in $allPublishers)
{
    Write-Host $publisher.PublisherName
    $offers = Get-AzureRmVMImageOffer -Location westus2 -PublisherName $publisher.PublisherName
    foreach ( $offer in $offers)
    {
        Write-Host $offer.Offer
        $SKUs = Get-AzureRmVMImageSku -Location westus2 -PublisherName $publisher.PublisherName -Offer $offer.Offer
        foreach ($sku in $SKUs)
        {
            $images = Get-AzureRmVMImage -Location westus2 -PublisherName  $publisher.PublisherName -Offer $offer.Offer -Skus $sku.Skus
            foreach ($image in $images)
            {
                Write-Host "$($image.PublisherName) $($image.Offer) $($image.Skus) $($image.Version)"
                Add-Content -Value "$($image.PublisherName) $($image.Offer) $($image.Skus) $($image.Version)" -Path .\temp\watcher-images.txt -Verbose
            }
        }
    }
}