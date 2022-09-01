#set ip and dns to dhcp
function set-dhcp
{
$global:interfaceindex = Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object ifindex -ExpandProperty ifindex
$Global:interfacename = Get-NetIPInterface -InterfaceIndex $interfaceindex -AddressFamily IPv4 | select interfacealias -ExpandProperty interfacealias
$Global:setdhcp = "netsh interface ip set address '$interfacename' dhcp" 
$Global:setdnsdhcp = "netsh interface ip set dns '$interfacename' dhcp" 
Invoke-expression -command "$setdhcp"
Invoke-expression -command "$setdnsdhcp"
}
#enable adapter if required
function Enable-Adapter
{
Get-NetAdapter |? status -NE Enabled | Enable-NetAdapter
}
$getdisabledadapters = Get-NetAdapter |? status -ne enabled
#query device and perform required fix
$networkadapterstatus = if($getdisabledadapters -ne $null)
{"no adapter found - enabling disabled adapters and setting dhcp"
enable-adapter
set-dhcp
}
else
{"Resetting DHCP"
set-dhcp
}

$networkadapterstatus