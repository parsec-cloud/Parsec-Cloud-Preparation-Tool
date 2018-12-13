### Written by James Stringer for Parsec Cloud Inc ###
### http://parsecgaming.com ###
### Contribute: 

$path = [Environment]::GetFolderPath("Desktop")
$currentusersid = Get-LocalUser "$env:USERNAME" | Select-Object SID | ft -HideTableHeaders | Out-String | ForEach-Object { $_.Trim() }

#moving initial files to correct place

New-Item -Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Startup -ItemType directory -ErrorAction SilentlyContinue | Out-Null 
New-Item -Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Shutdown -ItemType directory -ErrorAction SilentlyContinue | Out-Null
New-Item -Path $env:USERPROFILE\AppData\Roaming\ParsecLoader -ItemType directory | Out-Null
Move-Item -Path $path\ParsecTemp\PreInstall\psscripts.ini -Destination C:\Windows\system32\GroupPolicy\Machine\Scripts\ -Force | Out-Null
Move-Item -Path $path\ParsecTemp\PreInstall\NetworkRestore.ps1 -Destination C:\Windows\system32\GroupPolicy\Machine\Scripts\Shutdown 
Move-Item -Path $path\ParsecTemp\PreInstall\clear-proxy.ps1 -Destination $env:USERPROFILE\AppData\Roaming\ParsecLoader
Move-Item -Path $path\ParsecTemp\PreInstall\GPU-Update.ico -Destination $env:USERPROFILE\AppData\Roaming\ParsecLoader

function add-gpo-modifications {
$querygpt = Get-content C:\Windows\System32\GroupPolicy\gpt.ini
$matchgpt = $querygpt -match '{42B5FAAE-6536-11D2-AE5A-0000F87571E3}{40B6664F-4972-11D1-A7CA-0000F87571E3}'
if ($matchgpt -contains "*0000F87571E3*" -eq $false) {
write-output "Adding modifications to GPT.ini"
$gptstring = get-content C:\Windows\System32\GroupPolicy\gpt.ini
$gpoversion = $gptstring -match "Version"
$GPO = $gptstring -match "gPCMachineExtensionNames"
$add = '[{42B5FAAE-6536-11D2-AE5A-0000F87571E3}{40B6664F-4972-11D1-A7CA-0000F87571E3}]'
$replace = "$GPO" + "$add"
(Get-Content "C:\Windows\System32\GroupPolicy\gpt.ini").Replace("$GPO","$replace") | Set-Content "C:\Windows\System32\GroupPolicy\gpt.ini"
[int]$i = $gpoversion.trim("Version=") 
[int]$n = $gpoversion.trim("Version=")
$n +=2
(Get-Content C:\Windows\System32\GroupPolicy\gpt.ini) -replace "Version=$i", "Version=$n" | Set-Content C:\Windows\System32\GroupPolicy\gpt.ini}
else{write-output "Not Required"}
}

if (Test-Path ("C:\Windows\system32\GroupPolicy" + "\gpt.ini")) 
{add-gpo-modifications}
Else
{Move-Item -Path $path\ParsecTemp\PreInstall\gpt.ini -Destination C:\Windows\system32\GroupPolicy -Force | Out-Null}

regedit /s $path\ParsecTemp\PreInstall\NetworkRestore.reg
regedit /s $path\ParsecTemp\PreInstall\ForceCloseShutDown.reg
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS -ErrorAction SilentlyContinue | Out-Null
#create-directories
function create-directories {
Write-Output "Creating Directories in C:\ Drive"
New-Item -Path C:\ParsecTemp -ItemType directory | Out-Null
New-Item -Path C:\ParsecTemp\Apps -ItemType directory | Out-Null
New-Item -Path C:\ParsecTemp\DirectX -ItemType directory | Out-Null
New-Item -Path C:\ParsecTemp\Drivers -ItemType Directory | Out-Null
New-Item -Path C:\ParsecTemp\Devcon -ItemType Directory | Out-Null
}

#disable IE security
function disable-iesecurity {
Write-Output "Enabling Web Browsing on IE (Disabling IE Security)"
Set-Itemproperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -name IsInstalled -value 0 -force | Out-Null
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name IsInstalled -Value 0 -Force | Out-Null
Stop-Process -Name Explorer -Force
}

#download-files-S3
function download-resources {
Write-Output "Downloading Resources"
(New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe", "C:\ParsecTemp\Apps\directx_Jun2010_redist.exe") 
(New-Object System.Net.WebClient).DownloadFile("https://s3.amazonaws.com/parsec-files-ami-setup/Devcon/devcon.exe", "C:\ParsecTemp\Devcon\devcon.exe")
(New-Object System.Net.WebClient).DownloadFile("https://s3.amazonaws.com/parsec-build/package/parsec-windows.exe", "C:\ParsecTemp\Apps\parsec-windows.exe")
(New-Object System.Net.WebClient).DownloadFile("https://s3.amazonaws.com/parseccloud/image/parsec+desktop.png", "C:\ParsecTemp\parsec+desktop.png")
(New-Object System.Net.WebClient).DownloadFile("https://s3.amazonaws.com/parseccloud/image/white_ico_agc_icon.ico", "C:\ParsecTemp\white_ico_agc_icon.ico")
(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/jamesstringerparsec/Cloud-GPU-Updater/master/GPU%20Updater%20Tool.ps1", "$env:APPDATA\ParsecLoader\GPU Updater Tool.ps1")
}

#install-base-files-silently
function install-windows-features {
Write-Output "Installing .Net 3.5, Direct Play and DirectX Redist 2010"
Start-Process -FilePath "C:\ParsecTemp\Apps\directx_jun2010_redist.exe" -ArgumentList '/T:C:\ParsecTemp\DirectX /Q'-wait
Start-Process -FilePath "C:\ParsecTemp\DirectX\DXSETUP.EXE" -ArgumentList '/silent' -wait
Install-WindowsFeature Direct-Play | Out-Null
Install-WindowsFeature Net-Framework-Core | Out-Null
}

#set update policy
function set-update-policy {
Write-Output "Disabling Windows Update"
new-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "DoNotConnectToWindowsUpdateInternetLocations" -Value "1" | Out-Null
new-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "UpdateServiceURLAlternative" -Value "http://intentionally.disabled" | Out-Null
new-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "WUServer" -Value "http://intentionally.disabled" | Out-Null
new-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name "WUSatusServer" -Value "http://intentionally.disabled" | Out-Null
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name "AUOptions" -Value 1 | Out-Null
new-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name "UseWUServer" -Value 1 | Out-Null
}

#set automatic time and timezone

function set-time {
Write-Output "Setting Time to Automatic"
Set-ItemProperty -path HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters -Name Type -Value NTP | Out-Null
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate -Name Start -Value 00000003 | Out-Null
}

#disable new network window
function disable-network-window {
Write-Output "Disabling New Network Window"
new-itemproperty -path HKLM:\SYSTEM\CurrentControlSet\Control\Network -name "NewNetworkWindowOff" | Out-Null
}

#Enable Pointer Precision
function enhance-pointer-precision {
Write-Output "Enabling Enhanced Pointer Precision"
Set-Itemproperty -Path 'HKCU:\Control Panel\Mouse' -Name MouseSpeed -Value 1 | Out-Null
}

#disable shutdown start menu
function remove-shutdown {
Write-Output "Disabling Shutdown Option in Start Menu"
New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoClose -Value 1 | Out-Null
}

#auto close apps
function force-close-apps {
Write-Output "Forcing Apps to close on shutdown"
$test = Test-Path -Path "HKCU:\Control Panel\Desktop\AutoEndTask"
if ($test -eq $true){
set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name AutoEndTasks -Value 1 | Out-Null
}
Else {
New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name AutoEndTasks -Value 1 | Out-Null
}
}

#show hidden items
function show-hidden-items {
Write-Output "Showing Hidden Files in Explorer"
set-itemproperty -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name Hidden -Value 1 | Out-Null
}

#show file extensions
function show-file-extensions {
Write-Output "Showing File Extensions"
Set-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -name HideFileExt -Value 0 | Out-Null
}

#disable logout start menu
function disable-logout {
Write-Output "Disabling Logout"
New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name StartMenuLogOff -Value 1 | Out-Null
}

#set wallpaper
function set-wallpaper {
Write-Output "Setting WallPaper"
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value C:\ParsecTemp\parsec+desktop.png | Out-Null
Stop-Process -ProcessName explorer
}

#disable recent start menu items
function disable-recent-start-menu {
New-Item -path HKLM:\SOFTWARE\Policies\Microsoft\Windows -name Explorer
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer -PropertyType DWORD -Name HideRecentlyAddedApps -Value 1
}

#enable auto login - remove user password
function autoLogin { Write-Host "This cloud machine needs to be set to automatically login - please use the Setup Auto Login shortcut + Instructions on the desktop to set this up when the script is finished" -ForegroundColor red 
(New-Object System.Net.WebClient).DownloadFile("https://download.sysinternals.com/files/AutoLogon.zip", "$env:APPDATA\ParsecLoader\Autologon.zip")
Expand-Archive "$env:APPDATA\ParsecLoader\Autologon.zip" -DestinationPath "$env:APPDATA\ParsecLoader"
$output = "
This application was provided by Mark Rusinovish from System Internals",
"https://docs.microsoft.com/en-us/sysinternals/downloads/autologon",
"",
"What this application does:  Enables your server to automatically login, so you can log into Parsec straight away.",
"When to use it: The first time you setup your server, or when you change your servers password.",
"",
"Instructions",
"Accept the EULA and enter the following details",
"Username: $env:username",
"Domain: $env:Computername",
"Password: The password you got from Azure/AWS/Google that you use to log into RDP"
$output | Out-File "$path\Auto Login Instructions.txt"

autoLoginShortCut
}

function autoLoginShortCut {
Write-Output "Create Auto Login Shortcut"
$Shell = New-Object -ComObject ("WScript.Shell")
$ShortCut = $Shell.CreateShortcut("$path\Setup Auto Logon.lnk")
$ShortCut.TargetPath="$env:USERPROFILE\AppData\Roaming\ParsecLoader\Autologon.exe"
$ShortCut.WorkingDirectory = "$env:USERPROFILE\AppData\Roaming\ParsecLoader";
$ShortCut.WindowStyle = 0;
$ShortCut.Description = "Setup AutoLogon Shortcut";
$ShortCut.Save()
}

#createshortcut
function Create-ClearProxy-Shortcut
{
Write-Output "Create ClearProxy shortcut"
$Shell = New-Object -ComObject ("WScript.Shell")
$ShortCut = $Shell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Clear-Proxy.lnk")
$ShortCut.TargetPath="powershell.exe"
$ShortCut.Arguments='-windowstyle hidden -ExecutionPolicy Bypass -File "%homepath%\AppData\Roaming\ParsecLoader\Clear-Proxy.ps1"'
$ShortCut.WorkingDirectory = "$env:USERPROFILE\AppData\Roaming\ParsecLoader";
$ShortCut.WindowStyle = 0;
$ShortCut.Description = "ClearProxy shortcut";
$ShortCut.Save()
}

#create shortcut for electron app
function create-shortcut-app {
Write-Output "Moving Parsec Electron shortcut to Desktop"
Copy-Item -Path $path\ParsecTemp\PostInstall\Parsec.lnk -Destination $path
}

function disable-server-manager {
Write-Output "Disable Auto Opening Server Manager"
Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask | Out-Null
}

#AWS Read Disk
function setup-read-disk {
Copy-Item -path $path\ParsecTemp\PostInstall\readDisk.ps1 -Destination "$env:appdata\ParsecLoader"
}

#AWS Init
function aws-init {
start-process powershell.exe -verb RunAS -argument "-file C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeInstance.ps1 -Schedule"
}

#AWS Clean up Desktop Items
function clean-aws {
remove-item -path "$path\EC2 Feedback.Website"
Remove-Item -Path "$path\EC2 Microsoft Windows Guide.website"
}

#AWS Specific tweaks
function aws-setup{
#clean-aws
Write-Output "Installing VNC, and installing audio driver"
(New-Object System.Net.WebClient).DownloadFile($(((Invoke-WebRequest -Uri https://www.tightvnc.com/download.php -UseBasicParsing).Links.OuterHTML -like "*Installer for Windows (64-bit)*").split('"')[1].split('"')[0]), "C:\ParsecTemp\Apps\tightvnc.msi")
(New-Object System.Net.WebClient).DownloadFile("http://rzr.to/surround-pc-download", "C:\ParsecTemp\Apps\razer-surround-driver.exe")
start-process msiexec.exe -ArgumentList '/i C:\ParsecTemp\Apps\TightVNC.msi /quiet /norestart ADDLOCAL=Server SET_USECONTROLAUTHENTICATION=1 VALUE_OF_USECONTROLAUTHENTICATION=1 SET_CONTROLPASSWORD=1 VALUE_OF_CONTROLPASSWORD=4ubg9sde SET_USEVNCAUTHENTICATION=1 VALUE_OF_USEVNCAUTHENTICATION=1 SET_PASSWORD=1 VALUE_OF_PASSWORD=4ubg9sde' -Wait
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value $env:USERNAME | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value "" | Out-Null
New-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogin -Value 1 | Out-Null
Write-Host "WAITING FOR YOU TO CLICK YES ON Razer Surround Driver - IT COULD BE HIDING BEHIND ANOTHER WINDOW" -ForegroundColor Red
Start-Process C:\ParsecTemp\Apps\razer-surround-driver.exe
Set-Service -Name audiosrv -StartupType Automatic
}

function gpu-update-shortcut {
(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/jamesstringerparsec/Cloud-GPU-Updater/master/GPU%20Updater%20Tool.ps1", "$ENV:Appdata\ParsecLoader\GPU Updater Tool.ps1")
Unblock-File -Path "$ENV:Appdata\ParsecLoader\GPU Updater Tool.ps1"
Write-Output "GPU-Update-Shortcut"
$Shell = New-Object -ComObject ("WScript.Shell")
$ShortCut = $Shell.CreateShortcut("$path\GPU Updater.lnk")
$ShortCut.TargetPath="powershell.exe"
$ShortCut.Arguments='-ExecutionPolicy Bypass -File "%homepath%\AppData\Roaming\ParsecLoader\GPU Updater Tool.ps1"'
$ShortCut.WorkingDirectory = "$env:USERPROFILE\AppData\Roaming\ParsecLoader";
$ShortCut.IconLocation = "$env:USERPROFILE\AppData\Roaming\ParsecLoader\GPU-Update.ico, 0";
$ShortCut.WindowStyle = 0;
$ShortCut.Description = "GPU Updater shortcut";
$ShortCut.Save()
}

#Provider specific driver install and setup
Function provider-specific
{
Write-Output "Doing provider specific customizations"
#Device ID Query 
$gputype = get-wmiobject -query "select DeviceID from Win32_PNPEntity Where (deviceid Like '%PCI\\VEN_10DE%') and (PNPClass = 'Display' or Name = '3D Video Controller')" | Select-Object DeviceID -ExpandProperty DeviceID

if($gputype.substring(13,8) -eq "DEV_13F2") {
#AWS G3.4xLarge M60
Write-Output "Tesla M60 Detected"
autologin
aws-setup
}
ElseIF($gputype.Substring(13,8) -eq "DEV_118A"){#AWS G2.2xLarge K520
autologin
aws-setup
Write-Output "GRID K520 Detected"
}
ElseIF($gputype.Substring(13,8) -eq "DEV_1BB1") {
#Paperspace P4000
Write-Output "Quadro P4000 Detected"
} 
Elseif($gputype.Substring(13,8) -eq "DEV_1BB0") {
#Paperspace P5000
Write-Output "Quadro P5000 Detected"
}
Elseif($gputype.substring(13,8) -eq "DEV_15F8") {
#Tesla P1000
Write-Output "Tesla P100 Detected"
autologin
aws-setup
}
Elseif($gputype.substring(13,8) -eq "DEV_1430") {
#Quadro M2000
Write-Output "Quadro M2000 Detected"
autologin
aws-setup
}
}

#Apps that require human intervention
function Install-Gaming-Apps {
Write-host "Installing Parsec - YOU WILL NEED TO MANUALLY CLICK THROUGH THIS, AND CLICK YES" -ForegroundColor Red
Start-Process -FilePath C:\ParsecTemp\Apps\Parsec-Windows.exe -wait
New-ItemProperty -path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name "Parsec.App.0" -Value "$ENV:AppData\Parsec\electron\parsec.exe" | Out-Null
Stop-Process -name parsec
Write-Output "app_host=1" | Out-File -FilePath $ENV:AppData\Parsec\config.txt -Encoding ascii
}

#Disable Devices
function disable-devices {
write-output "Disabling devices not required"
Start-Process -FilePath "C:\ParsecTemp\Devcon\devcon.exe" -ArgumentList '/r disable "HDAUDIO\FUNC_01&VEN_10DE&DEV_0083&SUBSYS_10DE11A3*"'
Start-Process -FilePath "C:\ParsecTemp\Devcon\devcon.exe" -ArgumentList '/r disable "PCI\VEN_1234&DEV_1111&SUBSYS_00015853*"'
Start-Process -FilePath "C:\ParsecTemp\Devcon\devcon.exe" -ArgumentList '/r disable "PCI\VEN_1013&DEV_00B8&SUBSYS_00015853*"'
}

#Cleanup
function clean-up {
Write-Output "Cleaning up!"
Remove-Item -Path C:\ParsecTemp\DirectX -force -Recurse 
Remove-Item -Path C:\ParsecTemp\Drivers -force -Recurse
Remove-Item -Path $path\ParsecTemp -force -Recurse
}

#cleanup recent files
function clean-up-recent {
Write-Output "Removing recent files"
remove-item "$env:APPDATA\Microsoft\Windows\Recent\*" -Recurse -Force | Out-Null
}

Write-Host -foregroundcolor cyan "
                                 #############                                 
                                 #############                                 
                                                                               
                           .#####   ###/  #########                            
                                                                               
                          ###########################                          
                          ###########################                          
                                                                               
                           .#########  /###   #####                            
                                                                               
                                 #############                                 
                                 #############                                 
                                       
                    ~Parsec Self Hosted Cloud Setup Script~

                    This script sets up your cloud computer
                    with a bunch of settings and drivers
                    to make your life easier.  
                    
                    It's provided with no warranty, 
                    so use it at your own risk.
                    
                    Check out the Readme.txt for more
                    information.

                    This tool supports:

                    OS:
                    Server 2016
                    
                    CLOUD SKU:
                    AWS G3.4xLarge    (Tesla M60)
                    AWS G2.2xLarge    (GRID K520)
                    Azure NV6         (Tesla M60)
                    Paperspace P4000  (Quadro P4000)
                    Paperspace P5000  (Quadro P5000)
                    Google P100       (Tesla P100)

"   
create-directories
disable-iesecurity
download-resources
install-windows-features
set-update-policy 
#remove-shutdown 
force-close-apps 
disable-network-window
disable-logout
show-hidden-items
show-file-extensions
enhance-pointer-precision
set-time
set-wallpaper
Create-ClearProxy-Shortcut
disable-server-manager
Install-Gaming-Apps
Write-Output "Done installing Parsec"
Start-Sleep -s 5
create-shortcut-app
gpu-update-shortcut
disable-devices
clean-up
clean-up-recent
provider-specific
Write-Host "All Done!",
"THINGS YOU NEED TO DO",
"1. Open Parsec and sign in",
"2. Open Setup Auto Logon on the Desktop and follow the instructions (in the text file on the Desktop)",
"3. Run GPU Updater Tool",
"4. If your computer doesn't reboot automatically, restart it from the Start Menu after GPU Updater Tool is finished" -ForegroundColor RED
pause