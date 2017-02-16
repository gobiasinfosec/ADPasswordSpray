#Gives you the list of active accounts, when they were created, last used and password last set. (Can help pick targets/create pw list)

Import-Module ActiveDirectory

$filename = Read-Host "Enter Name for Output File: "

Get-ADUser -filter {Enabled -eq $true} -Properties whencreated, lastlogondate, PasswordLastSet | Where-Object{$_.DistinguishedName -like "*OU=*" } | select Name, WhenCreated, PasswordLastSet, LastLogonDate | Export-Csv -path "c:\temp\$filename.csv"

echo "Results have been exported to c:\temp\$filename.csv"
