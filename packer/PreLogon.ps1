Write-Host "Setting wallpaper"
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies" -Name "System" | Out-Null
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name Wallpaper -PropertyType String -value "C:\ParsecTemp\parsec+desktop.png" | Out-Null
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name WallpaperStyle -PropertyType String -value 2 | Out-Null

Start-Sleep -s 1

Write-Host "Cleaning up and exiting..."

C:\Azure\LGPO_30\LGPO.exe /t 'C:\Azure\ScriptPolicies-Delete.txt'
& 'C:\Azure\LogonScript-Delete.ps1'
