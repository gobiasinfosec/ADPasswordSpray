Import-Module ActiveDirectory

#This will output file to c:\temp\AD_users.csv
Get-ADUser -filter * | Select-Object SamAccountName | Export-CSV -NoTypeInformation c:\temp\AD_users.csv
