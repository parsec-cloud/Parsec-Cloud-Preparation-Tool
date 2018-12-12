#this script loads all others
### Written by James Stringer for Parsec Cloud Inc ###
### http://parsecgaming.com ###
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
Write-Output "Setting up Environment"
$path = [Environment]::GetFolderPath("Desktop")
New-Item -Path $path\ParsecTemp -ItemType directory 
Unblock-File -Path .\*
copy-Item .\* -Destination $path\ParsecTemp\ -Recurse
#lil nap
Start-Sleep -s 1
#unblocking any files
Write-Output "Unblocking files just in case"
Get-ChildItem -Path $path\ParsecTemp -Recurse | Unblock-File
Write-Output "Starting the first script, this Window will close in 60 seconds"
start-process powershell.exe -verb RunAS -argument "-file $path\parsectemp\PostInstall\PostInstall.ps1"
Start-Sleep -Seconds 60