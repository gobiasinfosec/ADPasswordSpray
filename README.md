# ADPasswordSpray

These tools are used to run a list of passwords against a domain by waiting between passwords to spray a domain without locking any users out.

### Instructions

powershellspray.ps1 -> Look this over before you run it. By default it will pull the account lockout observation window from AD and set that as the sleep timer. It will then pull all accounts from AD and generate a wordlist based on the current date (+- 2 months) and spray against all accounts using the IPC share on the local computer. Any found passwords will be written to c:\temp. 

There are a number of parameters that you can configure, including an option to automatically send an email when a password is found, so look it over before running it. With a little tweaking this could be used to run completely in memory on a machine that you have a shell on. 

### Optional scripts

GetADUsers.ps1 -> This will enumerate AD for all users and output the SamAccountName to a csv. This will be your users input file

password_spray_AD.bat -> Once you've adjusted your timeout parameter, just provide this a password list and your users.csv file. For the machine to test against, you can use any machine on the domain. If you're on the domain, I'd recommend running it against the machine you're on. 

The other optional scripts are features that have been rolled into the powershellspray.ps1 script and are mostly informational. 


### Disclaimer

This has been provided for testing and academic purposes only. Do not use this tool against networks that you do not own or have express/strict written consent to test against. Do not use for illegal purposes.
