Import-Module $env:appdata\ParsecLoader\Modules\ShowDialog.psm1
$CountSinceStart = 0
Function CountSinceStart {$MinutesSinceStart = [int]3240 - $($(get-date) - $(Get-EventLog -LogName System -InstanceId 12 -Newest 1).TimeGenerated).TotalSeconds
If ($MinutesSinceStart -lt 0) {
$MinutesSinceStart = 0}
Else{}

Do {
$CountSinceStart++
Start-Sleep -s 1
}
Until 
(
$CountSinceStart -ge $MinutesSinceStart
)
ShowDialog -SubMessage "Stop your computer now if you don't want to pay another hour of game time."
}


CountSinceStart




