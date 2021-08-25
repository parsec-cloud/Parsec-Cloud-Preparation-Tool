# config
$powershell = "powershell.exe"
$scriptsMap = @{
    Logon = @{
        CmdLine = $powershell
        Parameters = "C:\Azure\PreLogon.ps1"
    }
    Logoff = @{
        CmdLine = ""
        Parameters = ""
    }
}
 
class Script {
    [string]$CmdLine
    [string]$Parameters
}
 
function Merge-Scripts {
    param(
        [string[]]$Contents,
        [ValidateSet('Logon', 'Logoff')]
        [string]$Type,
        [string]$CmdLine,
        [string]$Parameters
    )
    
    if (!$contents) {
        $contents = @();
    }
 
    $scripts = [Script[]]@()
    $collect = $false
 
    for ($i = 0; $i -lt $contents.Length; $i++) {
        if ($contents[$i] -eq "[$Type]") {
            $collect = $true
            continue
        }
        if ($collect -eq $true) {
            if ($contents[$i] -match "\[\w+\]") {
                break
            }
            if ($contents[$i].Length -gt 0) {
                $scripts += [Script]@{
                    CmdLine = ($contents[$i] -split "CmdLine=")[1]
                    Parameters = ($contents[$i + 1] -split "Parameters=")[1]
                }
                $i++
            }
        }
    }
 
    $cmdLine = $scriptsMap[$Type]["CmdLine"]
    $parameters = $scriptsMap[$Type]["Parameters"]
    
    $scripts = [Script[]]($scripts | Where-Object {$_.CmdLine -ne $cmdLine -or $_.Parameters -ne $parameters})
 
    if (-not ($cmdLine -eq "" -and $parameters -eq ""))
    {
        $scripts += [Script]@{
            CmdLine = $cmdLine
            Parameters = $parameters
        }
    }
 
    $contents = ""
    if ($scripts.Count -gt 0)
    {
        $contents = @("[$Type]")
 
        for ($i = 0; $i -lt $scripts.Count; $i++) {
            $contents += "$($i)CmdLine=$($scripts[$i].CmdLine)"
            $contents += "$($i)Parameters=$($scripts[$i].Parameters)"
        }
    }
 
    return $contents
}
 
function Read-ScriptsIni() {
    param(
        [string]$ScriptsPath
    )
 
    $parent = Split-Path -Path $scriptsPath
    if (!(Test-Path $parent)) {
        New-Item $parent -ItemType Directory | Out-Null
    }
    if (!(Test-Path $scriptsPath)) {
        New-Item $scriptsPath -ItemType File | Out-Null
    }
 
    return Get-Content $ScriptsPath -ErrorAction SilentlyContinue
}


# paths
$GpRoot = "${env:SystemRoot}\System32\GroupPolicy"
 
 
# logon/logoff scripts
$userScriptsPath = Join-Path $GpRoot "User\Scripts\scripts.ini"
$contents = Read-ScriptsIni -ScriptsPath $userScriptsPath
$logonScripts = Merge-Scripts -Contents $contents -Type Logon
$logoffScripts = Merge-Scripts -Contents $contents -Type Logoff

Set-Content $userScriptsPath -Value ($logonScripts + $logoffScripts) -Encoding Unicode -Force
 
# bumping machine/user script versions in gpt.ini
$GpIni = Join-Path $GpRoot "gpt.ini"
$MachineGpExtensions = '{35378EAC-683F-11D2-A89A-00C04FBBCFA2}{D02B1F72-3407-48AE-BA88-E8213C6761F1}'
$UserGpExtensions = '{42B5FAAE-6536-11D2-AE5A-0000F87571E3}{40B66650-4972-11D1-A7CA-0000F87571E3}'
 
$contents = Get-Content $GpIni -ErrorAction SilentlyContinue
$newVersion = 65537 # 0x00010001
 
$versionMatchInfo = $contents | Select-String -Pattern 'Version=(.+)'
if ($versionMatchInfo.Matches.Groups -and $versionMatchInfo.Matches.Groups[1].Success) {
    $newVersion += [int]::Parse($versionMatchInfo.Matches.Groups[1].Value)
}
 
(
    "[General]",
    "gPCMachineExtensionNames=[$MachineGpExtensions]",
    "Version=$newVersion",
    "gPCUserExtensionNames=[$UserGpExtensions]"
) | Out-File -FilePath $GpIni -Encoding ascii
 
# generating registry keys
gpupdate /force
