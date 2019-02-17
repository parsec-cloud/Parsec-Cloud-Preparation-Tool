# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}

Write-Host "This sets your machine to shutdown if Windows detects it as idle for X minutes.
This is intended to save you money if you ever forget to shut your machine down.
You will get a warning message pop up 10 minutes before shutdown"

[int]$read = read-host "How much time should the system idle for before shutting down? Time in Minutes - Minimum 20"
$time = $read - 10

$span = new-timespan -minutes $time

#https://www.ctrl.blog/entry/idle-task-scheduler-powershell
$TaskName = "Automatic Shutdown On Idle"

$service = New-Object -ComObject("Schedule.Service")
$service.Connect()
$rootFolder = $service.GetFolder("")

$taskdef = $service.NewTask(0)

# Creating task settings with some default properties plus
# the task’s idle settings; requiring 15 minutes idle time
$sets = $taskdef.Settings
$sets.AllowDemandStart = $true
$sets.Compatibility = 2
$sets.Enabled = $true
$sets.RunOnlyIfIdle = $true
$sets.IdleSettings.IdleDuration = "PT$($span.Hours)H$($span.Minutes)M"
$sets.IdleSettings.WaitTimeout = "PT0M"
$sets.IdleSettings.StopOnIdleEnd = $true

# Creating an reoccurring daily trigger, limited to execute
# once per 40-minutes.
$trg = $taskdef.Triggers.Create(2)
$trg.StartBoundary = ([datetime]::Now).ToString("yyyy-MM-dd'T'HH:mm:ss")
$trg.Enabled = $true
$trg.DaysInterval = 1
$trg.Repetition.Duration = "P1D"
$trg.Repetition.Interval = "PT$($span.Hours)H$($span.Minutes)M"
$trg.Repetition.StopAtDurationEnd = $true

# The command and command arguments to execute
$act = $taskdef.Actions.Create(0)
$act.Path = "C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe"
$act.Arguments = "-file %appdata%\ParsecLoader\Automatic-Shutdown.ps1"

# Register the task under the current Windows user
$user = [environment]::UserDomainName + "\" + [environment]::UserName
$rootFolder.RegisterTaskDefinition($TaskName, $taskdef, 6, $user, $null, 3) | Out-Null
"Scheduled Task successfully Created"
pause