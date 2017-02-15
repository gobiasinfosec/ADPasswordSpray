Import-Module ActiveDirectory

#This will output file to c:\temp\AD_users.csv, if searching for specific OU change it in the Where-Object pipe
Get-ADUser -filter {Enabled -eq $true} | Where-Object{$_.DistinguishedName -like "*OU=*" } | Select-Object SamAccountName | Export-CSV -NoTypeInformation c:\temp\AD_users.csv
