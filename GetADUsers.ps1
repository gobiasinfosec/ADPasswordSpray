# Retrieve ADUsers and export to CSV
# Then run a diff against your baseline and export it to a new CSV
# Finally rename your old baseline and change your export to your new baseline

Import-Module ActiveDirectory

#This will output file to c:\temp\AD_users.csv, if searching for specific OU change it in the Where-Object pipe
Get-ADUser -filter {Enabled -eq $true} | Where-Object{$_.DistinguishedName -like "*OU=*" } | Select-Object SamAccountName | Export-CSV -NoTypeInformation "c:\temp\AD_users.csv"

# Look for a baseline, if it does not exist, copy AD_users.csv as the baseline
if(!(Test-Path "c:\temp\baseline.csv")){Copy-Item "c:\temp\AD_users.csv" "c:\temp\baseline.csv"}

# Import both files and compare them. 
# '<=' indicates that the name exists in baseline.csv but not AD_users.csv
# '=>' indicates that the name exists in AD_users.csv but not baseline.csv
$file1 = import-csv -Path "C:\temp\baseline.csv"
$file2 = import-csv -Path "C:\temp\AD_users.csv"
Compare-Object $file1 $file2 -property SamAccountName | Export-CSV -NoTypeInformation "c:\temp\diff.csv"

#Rename the old baseline to baseline.csv.old and the new export to baseline.csv
Copy-Item "c:\temp\baseline.csv" "c:\temp\baseline.csv.old"
Copy-Item "c:\temp\AD_users.csv" "c:\temp\baseline.csv"
Remove-Item "c:\temp\AD_users.csv"

echo "Results can be found in C:\Temp\diff.csv"
echo " '<=' indicates that this user was removed"
echo " '=>' indicates that this is a new user"

PAUSE
