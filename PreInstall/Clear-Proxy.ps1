function Remove-Razer-Startup {
if (((Get-Item -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run).GetValue("Razer Synapse") -ne $null) -eq $true) 
{Remove-ItemProperty -path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "Razer Synapse"
"Removed Startup Item from Razer Synapse"}
Else {"Razer Startup Item not present"}
}
function checkGPUstatus {
$getdisabled = Get-WmiObject win32_videocontroller | Where-Object {$_.name -like '*NVIDIA*' -and $_.status -like 'Error'} | Select-Object -ExpandProperty PNPDeviceID
if ($getdisabled -ne $null) {"Enabling GPU"
$var = $getdisabled.Substring(0,21)
$arguement = "/r enable"+ ' ' + "*"+ "$var"+ "*"
Start-Process -FilePath "C:\ParsecTemp\Devcon\devcon.exe" -ArgumentList $arguement
}
Else {"Device is enabled"
Start-Process -FilePath "C:\ParsecTemp\Devcon\devcon.exe" -ArgumentList '/m /r'}
}
Function provider-specific {
Write-Output "Doing provider specific customizations"
#Device ID Query 
New-Item -path C:\ParsecTemp\Drivers -ItemType Directory -Force | Out-Null
$gputype = get-wmiobject -query "select DeviceID from Win32_PNPEntity Where deviceid Like '%PCI\\VEN_10DE%' and PNPClass = 'Display'" | Select-Object DeviceID -ExpandProperty DeviceID

$deviceuppdate = if($gputype.substring(13,8) -eq "DEV_13F2") {
#AWS G3.4xLarge M60
Write-Output "AWS G3.4xLarge Detected"
Start-BitsTransfer -Source https://s3.amazonaws.com/parsec-files-ami-setup/NvidiaDriver/M60.exe -Destination C:\ParsecTemp\Drivers
Start-Process -FilePath C:\ParsecTemp\Drivers\M60.exe -ArgumentList "/s /n" -Wait
}
ElseIF($gputype.Substring(13,8) -eq "DEV_118A")
{#AWS G2.2xLarge K520
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
Write-Output "Test Machine Detected"
Start-BitsTransfer -Source https://s3.amazonaws.com/parsec-files-ami-setup/NvidiaDriver/PX000.exe -Destination C:\ParsecTemp\Drivers
Start-Process -FilePath C:\ParsecTemp\Drivers\PX000.exe -ArgumentList "/s /n" -Wait
}
}
function DriverInstallStatus {
$checkdevicedriver = Get-WmiObject win32_videocontroller | Where-Object {$_.PNPDeviceID -like '*VEN_10DE*'}
if ($checkdevicedriver.name -eq "Microsoft Basic Display Adapter") {Write-output "Driver not installed"
provider-specific
Restart-Computer}
Else {checkGPUStatus}
}
DriverInstallStatus
Remove-Razer-Startup
function check-nvidia {
$nvidiasmiarg = "-i 0 --query-gpu=driver_model.current --format=csv,noheader"
$nvidiasmidir = "c:\program files\nvidia corporation\nvsmi\nvidia-smi" 
$nvidiasmiresult = Invoke-Expression "& `"$nvidiasmidir`" $nvidiasmiarg"
$nvidiadriverstatus = if($nvidiasmiresult -eq "WDDM") 
{"GPU Driver status is good"
}
ElseIf($nvidiasmiresult -eq "TCC")
{Write-Output "The GPU has incorrect mode TCC set - setting WDDM"
$nvidiasmiwddm = "-g 0 -dm 0"
$nvidiasmidir = "c:\program files\nvidia corporation\nvsmi\nvidia-smi" 
Invoke-Expression "& `"$nvidiasmidir`" $nvidiasmiwddm"
shutdown /r -t 0}
Else{}
$nvidiadriverstatus}
check-nvidia
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS -ErrorAction SilentlyContinue | Out-Null
function clear-proxy {
$value = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable
if ($value.ProxyEnable -eq 1) {
set-itemproperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable -value 0 | Out-Null
write-host "Disable proxy if required"
Start-Process "C:\Program Files\Internet Explorer\iexplore.exe"
Start-Sleep -s 5
Get-Process iexplore | Foreach-Object { $_.CloseMainWindow() | Out-Null } | stop-process –force}
Else {}}
function clear-proxy-paperspace {
$value = Get-ItemProperty 'HKU:\S-1-5-21-2402485384-1523249476-2267272849-1000\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable
if ($value.ProxyEnable -eq 1) {
set-itemproperty 'HKU:\S-1-5-21-2402485384-1523249476-2267272849-1000\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable -value 0 | Out-Null
write-host "Disable proxy if required"
Start-Process "C:\Program Files\Internet Explorer\iexplore.exe"
Start-Sleep -s 5
Get-Process iexplore | Foreach-Object { $_.CloseMainWindow() | Out-Null } | stop-process –force}
Else {}}
$gputype = get-wmiobject -query "select DeviceID from Win32_PNPEntity Where deviceid Like '%PCI\\VEN_10DE%' and PNPClass = 'Display'" | Select-Object DeviceID -ExpandProperty DeviceID
$deviceupdate = if($gputype.substring(13,8) -eq "DEV_1BB1") {
#P4000
clear-proxy-paperspace
}
ElseIF($gputype.Substring(13,8) -eq "DEV_1BB0"){#P5000
clear-proxy-paperspace}
Else {clear-proxy}
$deviceupdate
Start-Sleep -s 60
function Test-PendingReboot{
 if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { return $true }
 if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { return $true }
 if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) { return $true }
 try { 
   $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
   $status = $util.DetermineIfRebootPending()
   if(($status -ne $null) -and $status.RebootPending){
     return $true
   }
 }catch{}
 
 return $false
}
if (Test-PendingReboot -eq $true){shutdown /r -t 0}
Else {}