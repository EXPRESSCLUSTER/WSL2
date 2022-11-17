rem ***************************************
rem *              stop.bat               *
rem ***************************************

cd %CLP_SCRIPT_PATH%"
PowerShell .\Stop-PostgreSQL.ps1
set ret=%ERRORLEVEL%
echo ret: %ret%
exit %ret%