#https://github.com/gfody/PowershellModules/tree/master/RunAs
#https://serverfault.com/questions/784616/runas-netonly-with-credentials-saved
#---------------------------------------------------------------------
#enable powershell scripts to run
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
#---------------------------------------------------------------------
#Install module if get error on import module
#Install-Module -Name RunAs
#---------------------------------------------------------------------
#run: ConvertFrom-SecureString (Get-Credential 'domain\username').Password
#The output its going to be your encrypted password
#replace xxxx below with your encrypted password and `domain\username` too
Import-Module RunAs

$mycreds = New-Object Management.Automation.PSCredential('domain\username', (ConvertTo-SecureString 'xxxx'))

runas -netonly $mycreds "C:\Program Files\Microsoft SQL Server Management Studio 21\Release\Common7\IDE\SSMS.exe"

#Read-Host -Prompt "Press any key to continue..."
