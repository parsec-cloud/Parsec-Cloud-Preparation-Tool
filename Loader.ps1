cls
 Write-Host -foregroundcolor red "
                               ((//////                                
                             #######//////                             
                             ##########(/////.                         
                             #############(/////,                      
                             #################/////*                   
                             #######/############////.                 
                             #######/// ##########////                 
                             #######///    /#######///                 
                             #######///     #######///                 
                             #######///     #######///                 
                             #######////    #######///                 
                             ########////// #######///                 
                             ###########////#######///                 
                               ####################///                 
                                   ################///                 
                                     *#############///                 
                                         ##########///                 
                                            ######(*                   
                                                           
                           
                                       
                    ~Parsec Self Hosted Cloud Setup Script~

                    This script sets up your cloud computer
                    with a bunch of settings and drivers
                    to make your life easier.  
                    
                    It's provided with no warranty, 
                    so use it at your own risk.
                    
                    Check out the Readme.txt for more
                    information.

                    This tool supports:

                    OS:
                    Server 2016
                    Server 2019
                    
                    CLOUD SKU:
                    AWS G3.4xLarge    (Tesla M60)
                    AWS G2.2xLarge    (GRID K520)
                    AWS g4dn.xlarge   (Tesla T4)
                    AWS g4ad.4xlarge  (AMD Radeon Pro V520)
                    Azure NV6         (Tesla M60)
                    Paperspace P4000  (Quadro P4000)
                    Paperspace P5000  (Quadro P5000)
                    Google P100 VW    (Tesla P100 Virtual Workstation)
                    Google P4  VW    (Tesla P4 Virtual Workstation)
                    Google T4  VW    (Tesla T4 Virtual Workstation)
    
"                                         
Write-Output "Setting up Environment"
$path = [Environment]::GetFolderPath("Desktop")
if((Test-Path -Path $path\ParsecTemp ) -eq $true){
    } 
Else {
    New-Item -Path $path\ParsecTemp -ItemType directory| Out-Null
    }

Unblock-File -Path .\*
copy-Item .\* -Destination $path\ParsecTemp\ -Force -Recurse | Out-Null
#lil nap
Start-Sleep -s 1
#Unblocking all script files
Write-Output "Unblocking files just in case"
Get-ChildItem -Path $path\ParsecTemp -Recurse | Unblock-File
Write-Output "Starting main script"
start-process powershell.exe -verb RunAS -argument "-file $path\parsectemp\PostInstall\PostInstall.ps1"
Write-Host "You can close this window now...progress will happen on the Powershell Window that just opened" -backgroundcolor red
stop-process -Id $PID
