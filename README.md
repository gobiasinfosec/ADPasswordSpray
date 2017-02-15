# ADPasswordSpray

These tools are used to run a list of passwords against a domain by waiting between passwords to spray a domain without locking any users out.

###Instructions

I have not provided a password list with these scripts (yet). But I recommend running them in the following order:

GetADLockoutPolicy.ps1 -> Notice the Lockout time and adjust the password spraying script timeout accordingly

GetADUsers.ps1 -> This will enumerate AD for all users and output the SamAccountName to a csv. This will be your users input file

password_spray_AD.bat -> Once you've adjusted your timeout parameter, just provide this a password list and your users.csv file. For the machine to test against, you can use any machine on the domain. If you're on the domain, I'd recommend running it against the machine you're on. 

###Disclaimer

This has been provided for testing and academic purposes only. Do not use this tool against networks that you do not own or have express/strict written consent to test against. Do not use for illegal purposes.
