#https://github.com/gfody/PowershellModules/tree/master/RunAs
#https://serverfault.com/questions/784616/runas-netonly-with-credentials-saved
#---------------------------------------------------------------------
#enable powershell scripts to run
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
#---------------------------------------------------------------------
#Install module if get error on import module
#Install-Module -Name RunAs
#---------------------------------------------------------------------
#run: ConvertFrom-SecureString (Get-Credential 'nh\hsantamarar').Password
#The output its going to be your encrypted password
#if theres no output you can get the password with the following command:
#"W':fQmIuCY#54f6" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
#replace xxxx below with your encrypted password and `domain\username` too
Import-Module RunAs

$mycreds = New-Object Management.Automation.PSCredential('nh\hsantamarar', (ConvertTo-SecureString '01000000d08c9ddf0115d1118c7a00c04fc297eb010000000272dd9868301a49aa5eb75212307fda000000000200000000001066000000010000200000009c10caf21123790b74fbbe2e515b1dc05ecd70269b73378173f5e06490ffa81f000000000e8000000002000020000000a88c17d55bd0ad25e989ff1d21ffba3a018b61af0546996c3a684fd2c3d1731520000000b944616e73f4c2abc81ba6322ce49cf06b48cdc867c864bd0b8a20bd5390b13d4000000068218b8e1e3d17fbdf9c11de36ec1a425db19bacca5656ee0d0a01a183e6874a786c7e567637c81d067d0f1a20e5a402d08386d0fa52d0a7208eb720d319dbd7'))

runas -netonly $mycreds "C:\Program Files\Microsoft SQL Server Management Studio 22\Release\Common7\IDE\SSMS.exe"

#Read-Host -Prompt "Press any key to continue..."
