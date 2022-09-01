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

                           ~Hovercast VCR Cloud Prep Tool~
"          

Write-Output "Setting up Environment"
$path = [Environment]::GetFolderPath("Desktop")
if((Test-Path -Path $path\HovercastTemp ) -eq $true){
    } 
Else {
    New-Item -Path $path\HovercastTemp -ItemType directory| Out-Null
    }

Unblock-File -Path .\*
copy-Item .\* -Destination $path\HovercastTemp\ -Force -Recurse | Out-Null
#lil nap
Start-Sleep -s 1
#Unblocking all script files
Write-Output "Unblocking files just in case"
Get-ChildItem -Path $path\HovercastTemp -Recurse | Unblock-File
Write-Output "Starting main script"
start-process powershell.exe -verb RunAS -argument "-file $path\HovercastTemp\PostInstall\PostInstall.ps1"
Write-Host "You can close this window now...progress will happen on the Powershell Window that just opened" -backgroundcolor red
stop-process -Id $PID