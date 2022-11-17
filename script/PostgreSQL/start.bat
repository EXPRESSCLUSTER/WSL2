rem ***************************************
rem *              start.bat              *
rem ***************************************


rem ***************************************
rem Check startup attributes
rem ***************************************
IF "%CLP_EVENT%" == "RECOVER" GOTO RECOVER

cd %CLP_SCRIPT_PATH%"
PowerShell .\Start-PostgreSQL.ps1
set ret=%ERRORLEVEL%
echo ret: %ret%
exit %ret%


rem ***************************************
rem Recovery process
rem ***************************************
:RECOVER

rem *************
rem Recovery process after return to the cluster
rem *************

GOTO EXIT

:EXIT
exit 0