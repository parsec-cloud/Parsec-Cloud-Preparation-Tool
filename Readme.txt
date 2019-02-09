                                 #############                                 
                                 #############                                 
                                                                               
                           .#####   ###/  #########                            
                                                                               
                          ###########################                          
                          ###########################                          
                                                                               
                           .#########  /###   #####                            
                                                                               
                                 #############                                 
                                 #############                                 
                                       
                    ~Parsec Self Hosted Cloud Setup Script~

This script sets up your cloud computer with a bunch of settings and drivers
to make your life easier.  
                    
It's provided with no warranty, so use it at your own risk.

Instructions:                    
1. Set up your GPU accelerated virtual machine on Microsoft Azure, Amazon AWS, Google Cloud or Paperspace 
2. Log in via RDP and remember the password
3. Open Powershell 
4. Copy the below code and follow the instructions in the script.

[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
(New-Object System.Net.WebClient).DownloadFile("https://github.com/jamesstringerparsec/Parsec-Cloud-Preparation-Tool/archive/master.zip","$ENV:UserProfile\Downloads\Parsec-Cloud-Preparation-Tool.zip") 
New-Item -Path $ENV:UserProfile\Downloads\Parsec-Cloud-Preparation-Tool -ItemType Directory
Expand-Archive $ENV:UserProfile\Downloads\Parsec-Cloud-Preparation-Tool.Zip -DestinationPath $ENV:UserProfile\Downloads\Parsec-Cloud-Preparation-Tool
CD $ENV:UserProfile\Downloads\Parsec-Cloud-Preparation-Tool\Parsec-Cloud-Preparation-Tool-master\
Powershell.exe -File $ENV:UserProfile\Downloads\Parsec-Cloud-Preparation-Tool\Parsec-Cloud-Preparation-Tool-master\Loader.ps1






This tool supports:

OS:
Server 2016
                    
CLOUD SKU:
AWS G3.4xLarge    (Tesla M60)
AWS G2.2xLarge    (GRID K520)
Azure NV6         (Tesla M60)
Paperspace P4000  (Quadro P4000)
Paperspace P5000  (Quadro P5000)
Google P100 VW    (Tesla P100 with Virtual Workstation Driver)

Issues:
Q. Stuck at downloading resouces for more than 1 minute
A. Close the Powershell window, delete the "ParsecTemp" folder on the Desktop, 
   then right click Loader.ps1 from the extracted Zip and select "Run with Powershell" 
   You may see errors, but it will still work.

Q. Google P100 is stuck at 1366x768
A. You should delete your machine and use the Virtual Workstation variety of the P100 Instance 
   which will allow you to go up to 4K

Q. What about GPU X or Cloud Server Y - when will they be supported?
A. That's on you to test the script and describe the errors you see.



