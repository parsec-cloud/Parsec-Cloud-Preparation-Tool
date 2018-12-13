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
1. Download https://github.com/jamesstringerparsec/Parsec-Cloud-Preparation-Tool/archive/master.zip
2. Extract the Zip File
3. Right Click Loader.ps1 and select "Run with Powershell"
4. If you're asked to make changes to the execution policy, press A, and Enter.
5. Let the Script run and follow instructions.

This tool supports:

OS:
Server 2016
                    
CLOUD SKU:
AWS G3.4xLarge    (Tesla M60)
AWS G2.2xLarge    (GRID K520)
zure NV6          (Tesla M60)
Paperspace P4000  (Quadro P4000)
Paperspace P5000  (Quadro P5000)
Google P100       (Tesla P100)

Issues:
Q. Stuck at downloading resouces for more than 1 minute
A. Close the Powershell window, then right click Loader.ps1 from the extracted Zip and select "Run with Powershell" 
   You may see errors, but it will still work.

Q. Google P100 is stuck at 1366x768
A. I think this may be a limitation of the free driver we're using, though normally an unlicensed virtual workstation grid driver allows
   you to max out at 2560x1600 on the M60 at least, I'm not sure about the P100

Q. What about GPU X or Cloud Server Y - when will they be supported?
A. That's on you!



