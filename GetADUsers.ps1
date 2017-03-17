# Retrieve ADUsers and export to CSV and create a diff from baseline

Import-Module ActiveDirectory

# Set filepaths for variables
$baseline = "c:\temp\baseline.csv"
$output = "c:\temp\AD_users.csv"
$diff = "c:\temp\diff_" + (Get-Date -Format "MM-dd-yyyy") + ".csv."
$ou = "*OU=*"

# This do the lookup and create the output file
echo "AD-Lookup running, do not close window"
Get-ADUser -filter {Enabled -eq $true} | Where-Object{$_.DistinguishedName -like $ou } | Select-Object SamAccountName | Export-Csv -NoTypeInformation $output

# Look for a baseline, if it does not exist, copy output as the baseline
if(!(Test-Path $baseline)){Copy-Item $output $baseline}

# Import both files and compare them. 
$file1 = Import-Csv -Path $baseline
$file2 = Import-Csv -Path $output
Compare-Object $file1 $file2 -property SamAccountName | Export-Csv -NoTypeInformation $diff

#Rename the old baseline to baseline.csv.old and the new export to baseline.csv
Copy-Item $baseline "$baseline.old"
Copy-Item $output $baseline
Remove-Item $output

#Replace arrows with more descriptive text in output file
(Get-Content $diff).replace('<=', 'Removed') | Set-Content $diff
(Get-Content $diff).replace('=>', 'New User') | Set-Content $diff

echo "Results can be found in $diff"
