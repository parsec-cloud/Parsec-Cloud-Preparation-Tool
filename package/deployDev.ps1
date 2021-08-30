Param (
  [String] $resourceGroup
)

function Get-StorageAccountName {
    param (
        [String] $connectionString,
        [String] $releaseFolder
    )
    $acctName = ""
    $bla = $connectionString.Split(";")
    foreach($item in $bla) {
        $kv = ([String]$item).Split("=")
        if($kv[0] -eq "AccountName") {
            $acctName = $kv[1]
            break
        }
    }

    Write-Output ("https://" + $acctName + ".blob.core.windows.net/" + $releaseFolder + "/")
}

$config = (Get-Content  "config.json" -Raw) | ConvertFrom-Json
$location = $config.location
$adminPass = $config.adminPass
$storageCS = $config.storageConnectionString
$teamId = $config.teamId
$teamKey = $config.teamKey
$userEmail = $config.userEmail

$releaseFolder = ('dev' + (get-date).ToString('MMddyyhhmmss'))
.\package.ps1 $releaseFolder

Set-Location ".\$releaseFolder"
Expand-Archive "marketplacePackage.zip"
Set-Location ".\marketplacePackage"
az storage container create -n $releaseFolder --connection-string $storageCS
az storage blob upload -c ($releaseFolder) -f "PostInstall.ps1" -n "PostInstall.ps1" --connection-string $storageCS
az storage blob upload -c ($releaseFolder) -f "PreInstall.zip" -n "PreInstall.zip" --connection-string $storageCS

$containerLocation = Get-StorageAccountName $storageCS $releaseFolder

$end = (Get-Date).ToUniversalTime()
$end = $end.addYears(1)
$endsas = ($end.ToString("yyyy-MM-ddTHH:mm:ssZ"))
$sas = az storage container generate-sas -n $releaseFolder --https-only --permissions r --expiry $endsas -o tsv --connection-string $storageCS
$sas = ("?" + $sas)
Set-Location "..\..\"
Set-Location "..\arm"
az group create -n $resourceGroup -l $location
az deployment group create -f mainTemplate.json --parameters "@createUiDefinition.parameters.json" -g $resourceGroup --parameters location=$location --parameters adminPass=$adminPass --parameters parsec_teamId=$teamId --parameters parsec_teamKey=$teamKey --parameters parsec_userEmail=$userEmail --parameter parsec_host=$resourceGroup --parameter _artifactsLocation=$containerLocation --parameter _artifactsLocationSasToken="""$sas"""
Set-Location "..\package"
