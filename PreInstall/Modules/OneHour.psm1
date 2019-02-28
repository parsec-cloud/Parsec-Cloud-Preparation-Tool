function OneHour {
Import-Module $env:appdata\ParsecLoader\Modules\ShowDialog.psm1
$Seconds = get-content -Path $env:Appdata\ParsecLoader\Time.txt
$Count = 0
do {
$Count++
Start-Sleep -s 1
}
Until(
$Count -ge $Seconds
)
ShowDialog -SubMessage "Stop your computer now if you don't want to pay another hour of game time."
}
