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

This script sets up your cloud computer with a bunch of settings and drivers
to make your life easier.  
                    
It's provided with no warranty, so use it at your own risk.

For Microsoft Azure users you can deploy a server quicker by using the following template:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjamesstringerparsec%2FParsec-Cloud-Preparation-Tool%2Fmaster%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/></a>

Then fill in the details on the next page.


### Instructions:                    
1. Set up your GPU accelerated cloud machine on Microsoft Azure, Amazon AWS, Google Cloud or Paperspace. 
2. Azure, AWS, Google: Log in via RDP and make note of the password - you'll need it later - Paperspace: Connect via Paperspace web app.
3. Open Powershell on the cloud machine.
4. Copy the below code and follow the instructions in the script - you'll see them in RED

```
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"  
(New-Object System.Net.WebClient).DownloadFile("https://github.com/jamesstringerparsec/Parsec-Cloud-Preparation-Tool/archive/master.zip","$ENV:UserProfile\Downloads\Parsec-Cloud-Preparation-Tool.zip")  
New-Item -Path $ENV:UserProfile\Downloads\Parsec-Cloud-Preparation-Tool -ItemType Directory  
Expand-Archive $ENV:UserProfile\Downloads\Parsec-Cloud-Preparation-Tool.Zip -DestinationPath $ENV:UserProfile\Downloads\Parsec-Cloud-Preparation-Tool  
CD $ENV:UserProfile\Downloads\Parsec-Cloud-Preparation-Tool\Parsec-Cloud-Preparation-Tool-master\  
Powershell.exe -File $ENV:UserProfile\Downloads\Parsec-Cloud-Preparation-Tool\Parsec-Cloud-Preparation-Tool-master\Loader.ps1
```

This tool supports:

### OS:
Server 2016  
Server 2019  - I do not actually recommend Server 2019, seems to break stuff...investigating. 
                    
### CLOUD SKU:
AWS G3.4xLarge    (Tesla M60)  
AWS G2.2xLarge    (GRID K520)  
AWS G4dn.xLarge   (Tesla T4 with vGaming driver)  
Azure NV6         (Tesla M60)  
Paperspace P4000  (Quadro P4000)  
Paperspace P5000  (Quadro P5000)  
Google P100 VW    (Tesla P100 with Virtual Workstation Driver)  
Google P4 VW      (Tesla P4 with Virtual Workstation Driver)  
Google T4 VW      (Tesla T4 with Virtual Workstation Driver)  

### Issues:
Q. Stuck at 24%
A. Keep waiting, this installation takes a while.

Q. Google P100 is stuck at 1366x768  
A. You should delete your machine and use the Virtual Workstation variety of the P100 Instance 
   which will allow you to go up to 4K

Q. What about GPU X or Cloud Server Y - when will they be supported?  
A. That's on you to test the script and describe the errors you see.



