<# Powershell Code to start the process #>

[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 
$ScriptWebArchive = "https://github.com/Hovercast/VCR-Prep-Tool/archive/master.zip"  
$LocalArchivePath = "$ENV:UserProfile\Downloads\Hovercast-VCR-Prep-Tool"  
(New-Object System.Net.WebClient).DownloadFile($ScriptWebArchive, "$LocalArchivePath.zip")  
Expand-Archive "$LocalArchivePath.zip" -DestinationPath $LocalArchivePath -Force  
CD $LocalArchivePath\Parsec-Cloud-Preparation-Tool-master\ | powershell.exe .\HoverLoader.ps1  

cls
 Write-Host -foregroundcolor red "
                                       ,,,                                      
                                ,,,,,,,,,,,,,,,,,                               
                           ,,,,,,,,,,,,,,,,,,,,,,,,,,                           
                       ,,,,,,,,,,,,           ,,,,,,,,,,,,                      
                   ,,,,,,,,,,,                    ,,,,,,,,,,,,                  
              .,,,,,,,,,,,                            .,,,,,,,,,,,              
          ,,,,,,,,,,,,               ,,,,,,                ,,,,,,,,,,,,         
      ,,,,,,,,,,,,               ,,,,,,,,,,,,,,,               ,,,,,,,,,,,,     
  ,,,,,,,,,,,                ,,,,,,,,,,,,,,,,,,,,,,,               .,,,,,,,,,,, 
 ,,,,,,,,               ,,,,,,,,,,,,         ,,,,,,,,,,,                ,,,,,,,,
,,,,,,              ,,,,,,,,,,,,,,,              ,,,,,,,,,,,,             ,,,,,,
 ,,,,,,,,,.     ,,,,,,,,,,,,,,,,,,,,,,,              ,,,,,,,,,,,,     ,,,,,,,,,,
   ,,,,,,,,,,,,,,,,,,,,      ,,,,,,,,.                    ,,,,,,,,,,,,,,,,,,,,  
       (,,,,,,,,,,,                            ,              ,,,,,,,,,,,(      
   ,,(((((((,,,,,,,,,,,,                   ,,,,,,,,,     .,,,,,,,,,,,((((((/,,  
 ,,,,,,,,*      ,,,,,,,,,,,,              ,,,,,,,,,,,,,,,,,,,,,,,     ,,,,,,,,,,
,,,,,,               ,,,,,,,,,,,              ,,,,,,,,,,,,,,               ,,,,,
 ,,,,,,,,                ,,,,,,,,,,,.       .,,,,,,,,,,,                ,,,,,,,,
  ,,,,,,,,,,,,               ,,,,,,,,,,,,,,,,,,,,,,,               ,,,,,,,,,,,. 
      ,,,,,,,,,,,,               .,,,,,,,,,,,,,.               ,,,,,,,,,,,,     
           ,,,,,,,,,,,                ,,,,,                ,,,,,,,,,,,          
               ,,,,,,,,,,,.                           ,,,,,,,,,,,,              
                   ,,,,,,,,,,,,                   ,,,,,,,,,,,,                  
                        ,,,,,,,,,,,           ,,,,,,,,,,,                       
                            ,,,,,,,,,,,,,,,,,,,,,,,,,                           
                                ,,,,,,,,,,,,,,,,,                               
                                       ,,,  

                    ~Hovercast VCR Prep Script~
"          

Write-Output "Setting up Environment"
$path = [Environment]::GetFolderPath("Desktop")
if((Test-Path -Path $path\HovercastTemp ) -eq $true){
    } 
Else {
    New-Item -Path $path\HovercastTemp -ItemType directory| Out-Null
    }


Unblock-File -Path .\*

#lil nap
Start-Sleep -s 1
#Unblocking all script files

Write-Output "Unblocking files just in case"
Get-ChildItem -Path $path\HovercastTemp -Recurse | Unblock-File

Write-Output "Starting main script"
start-process powershell.exe -verb RunAS -argument "-file $path\HovercastTemp\PostInstall\PostInstall.ps1"
Write-Host "You can close this window now...progress will happen on the Powershell Window that just opened" -backgroundcolor red
stop-process -Id $PID



#Password Changer
$password = "ControlRoom!"
$secure = ConvertTo-SecureString $password -AsPlainText -Force
Write-Output $secure
Get-LocalUser -Name "hovercast" | Set-LocalUser -Password $secure

<# Stop ServerManager from Launching on Startup by editing registry entry #>
Set-ItemProperty -Path HKCU:\Software\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -Value 1


<# Automatic Login so Parsec can run on startup and connect #>
$loginRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

Set-ItemProperty $loginRegPath "AutoAdminLogon" -Value "1" -type String 
Set-ItemProperty $loginRegPath "DefaultUsername" -Value "hovercast" -type String 
Set-ItemProperty $loginRegPath "DefaultPassword" -Value "ControlRoom!" -type String

<# Privacy Controls so apps can access camera and microphone #>
$privacyRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\"
Set-ItemProperty "$privacyRegPath\microphone" "value" -Value "Allow" -type String
Set-ItemProperty "$privacyRegPath\webcam" "value" -Value "Allow" -type String

<# Start to download and install apps #>
$basePath = "C:\Hovercast\temp\"
$latestRelease = Invoke-WebRequest https://github.com/obsproject/obs-studio/releases/latest -Headers @{"Accept"="application/json"}
# The releases are returned in the format {"id":3622206,"tag_name":"hello-1.0.0.11",...}, we have to extract the tag_name.
$json = $latestRelease.Content | ConvertFrom-Json
$latestVersion = $json.tag_name
$fileName = "OBS-Studio-$latestVersion-Full-Installer-x64.exe"
$Path = "$basePath$fileName"

$url = "https://github.com/obsproject/obs-studio/releases/latest/download/$fileName"

Write-Output $Path

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -URI $URL -OutFile $Path
