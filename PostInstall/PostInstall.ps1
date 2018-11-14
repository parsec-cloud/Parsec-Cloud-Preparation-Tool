$path = [Environment]::GetFolderPath("Desktop")
$currentusersid = Get-LocalUser "$env:USERNAME" | Select-Object SID | ft -HideTableHeaders | Out-String | ForEach-Object { $_.Trim() }

#moving initial files to correct place

New-Item -Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Startup -ItemType directory -ErrorAction SilentlyContinue | Out-Null 
New-Item -Path C:\Windows\system32\GroupPolicy\Machine\Scripts\Shutdown -ItemType directory -ErrorAction SilentlyContinue | Out-Null
New-Item -Path $env:USERPROFILE\AppData\Roaming\ParsecLoader -ItemType directory | Out-Null
Move-Item -Path $path\ParsecTemp\PreInstall\psscripts.ini -Destination C:\Windows\system32\GroupPolicy\Machine\Scripts\ -Force | Out-Null
Move-Item -Path $path\ParsecTemp\PreInstall\NetworkRestore.ps1 -Destination C:\Windows\system32\GroupPolicy\Machine\Scripts\Shutdown 
Move-Item -Path $path\ParsecTemp\PreInstall\clear-proxy.ps1 -Destination $env:USERPROFILE\AppData\Roaming\ParsecLoader


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
}

#disable IE security
function disable-iesecurity {
Write-Output "Disabling IE Security"
Set-Itemproperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -name IsInstalled -value 0 -force | Out-Null
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name IsInstalled -Value 0 -Force | Out-Null
Stop-Process -Name Explorer -Force
}

#download-files-S3
function download-resources {
Write-Output "Downloading Apps"
Start-BitsTransfer -Source https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe -Destination C:\ParsecTemp\Apps\ 
Start-Bitstransfer -source https://s3.amazonaws.com/parsec-files-ami-setup/Devcon/devcon.exe -Destination C:\ParsecTemp\Apps\
Start-BitsTransfer -Source https://s3.amazonaws.com/parsec-build/package/parsec-windows.exe -Destination C:\ParsecTemp\Apps\
Start-BitsTransfer -Source https://s3.amazonaws.com/parseccloud/image/parsec+desktop.png -Destination C:\ParsecTemp\
Start-BitsTransfer -Source https://s3.amazonaws.com/parseccloud/image/white_ico_agc_icon.ico -Destination C:\ParsecTemp\
}


#install-base-files-silently
function install-windows-features {
Write-Output "Installing .Net 3.5, Direct Play and DirectX Redist 2010"
Start-Process -FilePath "C:\ParsecTemp\Apps\directx_jun2010_redist.exe" -ArgumentList '/T:C:\ParsecTemp\DirectX /Q'-wait
Start-Process -FilePath "C:\ParsecTemp\DirectX\DXSETUP.EXE" -ArgumentList '/silent' -wait
Install-WindowsFeature Direct-Play | Out-Null
Install-WindowsFeature Net-Framework-Core | Out-Null
}


#setup Pip
Function setup-pip {
Write-Output "Setting up Pip" 
pip install requests | Out-Null
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
Write-Output "Setting time to Automatic"
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
#New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoClose -Value 1
New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoClose -Value 1 | Out-Null
}

#auto close apps
function force-close-apps {
Write-Output "Forcing Apps to close on shutdown"
New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name AutoEndTasks -Value 1 | Out-Null
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
#New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name StartMenuLogOff -Value 1
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

function auto-login {
Write-Output "Administrator password to blank"
secedit /export /cfg c:\secpol.cfg
(gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
rm -force c:\secpol.cfg -confirm:$false
cmd.exe /c 'C:\users\%username%\Desktop\ParsecTemp\PostInstall\Password.bat'
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
clean-aws
auto-login
Write-Output "Installing VNC, Setting Auto Login, writing Json File, and changing computer name to Parsec-AWS"
New-Item -Path C:\ParsecTemp\VirtualAudioCable -ItemType Directory| Out-Null
Start-BitsTransfer -source https://s3.amazonaws.com/parsec-files-ami-setup/VNC/tightvnc.msi -Destination C:\ParsecTemp\Apps\
Start-Bitstransfer -source https://s3.amazonaws.com/parsec-files-ami-setup/VirtualAudioCable/VirtualAudioCable.zip -Destination C:\ParsecTemp\Apps\
start-process msiexec.exe -ArgumentList '/i C:\ParsecTemp\Apps\TightVNC.msi /quiet /norestart ADDLOCAL=Server SET_USECONTROLAUTHENTICATION=1 VALUE_OF_USECONTROLAUTHENTICATION=1 SET_CONTROLPASSWORD=1 VALUE_OF_CONTROLPASSWORD=4ubg9sde SET_USEVNCAUTHENTICATION=1 VALUE_OF_USEVNCAUTHENTICATION=1 SET_PASSWORD=1 VALUE_OF_PASSWORD=4ubg9sde' -Wait
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value $env:USERNAME | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value "" | Out-Null
New-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogin -Value 1 | Out-Null
Rename-Computer -NewName "Parsec-AWS"
Expand-Archive C:\ParsecTemp\Apps\VirtualAudioCable.zip -DestinationPath C:\ParsecTemp\VirtualAudioCable\ 
Write-Output "WAITING FOR YOU TO CLICK YES ON VIRTUAL AUDIO CABLE - IT COULD BE HIDING BEHIND ANOTHER WINDOW"
Start-Process C:\ParsecTemp\VirtualAudioCable\setup64.exe -Wait -NoNewWindow
Set-Service -Name audiosrv -StartupType Automatic
}

#Provider specific driver install and setup
Function provider-specific
{
Write-Output "Doing provider specific customizations"
#Device ID Query 
$gputype = get-wmiobject -query "select DeviceID from Win32_PNPEntity Where deviceid Like '%PCI\\VEN_10DE%' and PNPClass = 'Display'" | Select-Object DeviceID -ExpandProperty DeviceID

$deviceuppdate = if($gputype.substring(13,8) -eq "DEV_13F2") {
#AWS G3.4xLarge M60
Write-Output "AWS G3.4xLarge Detected"
aws-setup
Start-BitsTransfer -Source https://s3.amazonaws.com/parsec-files-ami-setup/NvidiaDriver/M60.exe -Destination C:\ParsecTemp\Drivers
Start-Process -FilePath C:\ParsecTemp\Drivers\M60.exe -ArgumentList "/s /n" -Wait
}
ElseIF($gputype.Substring(13,8) -eq "DEV_118A")
{#AWS G2.2xLarge K520
aws-setup
Write-Output "AWS G2.2xLarge Detected"
Start-BitsTransfer -Source https://s3.amazonaws.com/parsec-files-ami-setup/NvidiaDriver/K520.exe -Destination C:\ParsecTemp\Drivers
Start-Process -FilePath C:\ParsecTemp\Drivers\K520.exe -ArgumentList "/s /n" -Wait
}
ElseIF($gputype.Substring(13,8) -eq "DEV_1BB1") {
#Paperspace P4000
Write-Output "Paperspace P4000 Detected"
Start-BitsTransfer -Source https://s3.amazonaws.com/parsec-files-ami-setup/NvidiaDriver/PX000.exe -Destination C:\ParsecTemp\Drivers
Start-Process -FilePath C:\ParsecTemp\Drivers\PX000.exe -ArgumentList "/s /n" -Wait
} 
Elseif($gputype.Substring(13,8) -eq "DEV_1BB0") {
#Paperspace P5000
Write-Output "Paperspace P5000 Detected"
Start-BitsTransfer -Source https://s3.amazonaws.com/parsec-files-ami-setup/NvidiaDriver/PX000.exe -Destination C:\ParsecTemp\Drivers
Start-Process -FilePath C:\ParsecTemp\Drivers\PX000.exe -ArgumentList "/s /n" -Wait
}
Elseif($gputype.Substring(13,8) -eq "DEV_1430") {
#Paperspace M2000 -Test
aws-setup
Write-Output "Test Machine Detected"
Start-BitsTransfer -Source https://s3.amazonaws.com/parsec-files-ami-setup/NvidiaDriver/PX000.exe -Destination C:\ParsecTemp\Drivers
Start-Process -FilePath C:\ParsecTemp\Drivers\PX000.exe -ArgumentList "/s /n" -Wait
}
}

#Apps that require human intervention
function Install-Gaming-Apps {
Write-Output "Installing Parsec - YOU WILL NEED TO MANUALLY CLICK THROUGH THIS, AND CLICK YES"
Start-Process -FilePath C:\ParsecTemp\Apps\Parsec-Windows.exe -wait
New-ItemProperty -path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name "Parsec.App.0" -Value "$ENV:AppData\Parsec\electron\parsec.exe hidden=1" | Out-Null
Stop-Process -name parsec
Write-Output "app_host=1" | Out-File -FilePath $ENV:AppData\Parsec\config.txt -Encoding ascii
}

#Disable Devices
function disable-devices {
write-output "Disabling devices not required"
Start-Process -FilePath "C:\ParsecTemp\Apps\devcon.exe" -ArgumentList '/r disable "HDAUDIO\FUNC_01&VEN_10DE&DEV_0083&SUBSYS_10DE11A3*"'
Start-Process -FilePath "C:\ParsecTemp\Apps\devcon.exe" -ArgumentList '/r disable "PCI\VEN_1234&DEV_1111&SUBSYS_00015853*"'
Start-Process -FilePath "C:\ParsecTemp\Apps\devcon.exe" -ArgumentList '/r disable "PCI\VEN_1013&DEV_00B8&SUBSYS_00015853*"'
}

#Cleanup
function clean-up {
Write-Output "Cleaning up!"
Remove-Item -Path C:\ParsecTemp\DirectX -force -Recurse 
Remove-Item -Path C:\ParsecTemp\Drivers -force -Recurse
Remove-Item -Path C:\ParsecTemp\Apps -force -Recurse | Out-Null
Remove-Item -Path $path\ParsecTemp -force -Recurse
remove-item -Path "$path\ParsecPrep" -Recurse -Force
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


                    
"   

create-directories
disable-iesecurity
download-resources
install-windows-features
set-update-policy 
remove-shutdown 
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
#provider-specific
Install-Gaming-Apps
Write-Output "Done installing apps"
Start-Sleep -s 5
create-shortcut-app
disable-devices
clean-up
clean-up-recent
Write-Output "All Done"
Start-Sleep -s 60
#Restart-Computer