Param (
  [String] $releaseFolder = ('release_' + (get-date).ToString('MMddyyhhmmss'))
)

$tempFolder = "temp"
New-Item -Path $releaseFolder -ItemType directory -Force

Set-Location $releaseFolder

New-Item -Path $tempFolder -ItemType directory -Force

Set-Location $tempFolder

Copy-Item "..\..\..\arm\createUiDefinition.json"
Copy-Item "..\..\..\arm\mainTemplate.json"
Copy-Item "..\..\..\PostInstall\PostInstall.ps1"

Set-Location "..\"
Compress-Archive -Path ".\temp\*" -DestinationPath ".\marketplacePackage.zip"
Remove-Item -Path $tempFolder -Recurse
Set-Location "..\"
