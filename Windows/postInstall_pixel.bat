:: supress commands
@echo off

goto check_Permissions

:check_Permissions
    echo Administrative permissions required. Checking permissions...

    net session >nul 2>&1
    if %errorLevel% == 0 (
        echo Success: Administrative permissions confirmed.
        goto :check_Deliberate
    ) else (
        echo Failure: Current permissions inadequate.
        echo Right-click script and run as Administrator.
        pause >nul
    )


:: check that script launch was deliberate.
:check_Deliberate
	set /P c=Are you sure you want to run this script?. [Y/N]?
	if /I "%c%" EQU "Y" goto :begin_Script
	if /I "%c%" EQU "N" goto :exit_Script
	goto :check_Deliberate

:begin_Script

:: ==========================
:: MAP DRIVES
:: ==========================
echo Mapping network drive(s).
:: ask for credentials
set /P user=Enter MegaRAID username:"
set /P pswd="Enter MegaRAID password:"
:: map drives
net use Z: \\megaraid\MegaRAID /user:%user% %pswd% /persistent:Yes
:: clear credentials
set "user="
set "pswd="

:: ==========================
:: WINDOWS SETTINGS
:: ==========================
:win_A
	set /P c=Disable Hibernation? [Y/N]? [do not disable if this is a laptop]
	if /I "%c%" EQU "Y" goto :win_A_Y
	if /I "%c%" EQU "N" goto :win_A_N
	goto win_A
	:win_A_Y
		powercfg.exe /hibernate off
		echo Hibernation disabled.
		goto win_B
	:win_A_N
		echo Hibernation unchanged.
		goto win_B
:win_B
	set /P c=Set Energy Plan to High Performance? [Y/N]?
	if /I "%c%" EQU "Y" goto :win_B_Y
	if /I "%c%" EQU "N" goto :win_B_N
	goto win_B
	:win_B_Y
		powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
		echo Energy Plan set to High Performance.
		goto win_C
	:win_B_N
		echo Energy Plan unchanged.
		goto win_C
:win_C
	set /P c=Disable Windows Update? [Y/N]?
	if /I "%c%" EQU "Y" goto :win_C_Y
	if /I "%c%" EQU "N" goto :win_C_N
	goto win_C
	:win_C_Y
		net stop wuauserv
		net stop bits
		net stop dosvc
		echo Windows Update disabled. Confirmation = Stopped.
		sc query wuauserv
		sc query bits
		sc query dosvc
		goto win_End
	:win_C_N
		echo Windows Update unchanged.
		goto win_End
:win_End

set /P NVIDIA_CHECK=Install NVIDIA DisplayDriver? This can take a few minutes. [Y/N]?
	if /I "%NVIDIA_CHECK%" EQU "Y" goto :NVIDIA_CHECK_Y
	if /I "%NVIDIA_CHECK%" EQU "N" goto :NVIDIA_CHECK_N
	:NVIDIA_CHECK_Y
		echo Nvidia Drivers will be installed after all other software.
	:NVIDIA_CHECK_N
		echo Nvidia Drivers WILL NOT be installed.
pause

:: ==========================
:: INSTALL APPS
:: ==========================
echo =========================================================================
echo Unfortunately not all software can be installed without user interaction. 
echo          You will be required for the occasinoal button click.
echo      Software that can be installed silently will happen at the end.
echo =========================================================================
pause
:: path for apps to install from
set REPO_PATH=Z:\Repositories\_INSTALLERS
:: reset install counter
set APP_COUNT=0
:: number of apps to install
set APP_TOTAL=15
:: PureRef
	set APP_PATH=PureRef
	set APP_NAME=PureRef*.*
	for /f "tokens=*" %%f in ('dir /b %REPO_PATH%\%APP_PATH%\%APP_NAME%') do (set FULL_PATH=%REPO_PATH%\%APP_PATH%\%%f)
	echo Installing %FULL_PATH%...
	START /WAIT %FULL_PATH%
	set /a "APP_COUNT+=1"
	echo Complete. %APP_COUNT% of %APP_TOTAL% installed
:: redshift
	set APP_PATH=Redshift3D
	set APP_NAME=Redshift*.*
	for /f "tokens=*" %%f in ('dir /b %REPO_PATH%\%APP_PATH%\%APP_NAME%') do (set FULL_PATH=%REPO_PATH%\%APP_PATH%\%%f)
	echo Installing %FULL_PATH%... CoreData will be set to shared repository.
	START /WAIT %FULL_PATH%
	set /a "APP_COUNT+=1"
	echo Complete. %APP_COUNT% of %APP_TOTAL% installed
:: substance
	set APP_PATH=Substance_Launcher
	set APP_NAME=Substance*.*
	for /f "tokens=*" %%f in ('dir /b %REPO_PATH%\%APP_PATH%\%APP_NAME%') do (set FULL_PATH=%REPO_PATH%\%APP_PATH%\%%f)
	echo Installing %FULL_PATH%...
	START /WAIT %FULL_PATH%
	set /a "APP_COUNT+=1"
	echo Complete. %APP_COUNT% of %APP_TOTAL% installed
:: zbrush
	set APP_PATH=ZBrush
	set APP_NAME=ZBrush*.*
	for /f "tokens=*" %%f in ('dir /b %REPO_PATH%\%APP_PATH%\%APP_NAME%') do (set FULL_PATH=%REPO_PATH%\%APP_PATH%\%%f)
	echo Installing %FULL_PATH%...
	START /WAIT %FULL_PATH%
	set /a "APP_COUNT+=1"
	echo Complete. %APP_COUNT% of %APP_TOTAL% installed
echo	
echo =========================================================================
echo        Software that can be installed silently will now proceed.
echo                   User action is no longer required.
echo					   May you have a blessed day.
echo =========================================================================
echo
:: adobe
	:: Illustrator
	echo Installing Illustrator...
	START /WAIT %REPO_PATH%\Adobe\Illustrator\Build\Illustrator.msi /quiet
	set /a "APP_COUNT+=1"
	echo Complete. %APP_COUNT% of %APP_TOTAL% installed
	:: InDesign
	echo Installing InDesign...
	START /WAIT %REPO_PATH%\Adobe\InDesign\Build\InDesign.msi /quiet
	set /a "APP_COUNT+=1"
	echo Complete. %APP_COUNT% of %APP_TOTAL% installed
	:: Photoshop
	echo Installing Photoshop...
	START /WAIT %REPO_PATH%\Adobe\Photoshop\Build\Photoshop.msi /quiet
	set /a "APP_COUNT+=1"
	echo Complete. %APP_COUNT% of %APP_TOTAL% installed
	:: After Effects & Premiere
	echo Installing AfterEffects and Premiere...
	START /WAIT %REPO_PATH%\Adobe\Premiere_AfterEffects\Build\Premiere_AfterEffects.msi /quiet
	set /a "APP_COUNT+=1"
	echo Complete. %APP_COUNT% of %APP_TOTAL% installed
:: chrome
	echo Installing Chrome
	START /WAIT %REPO_PATH%\Chrome\ChromeSetup.exe /silent /install
	set /a "APP_COUNT+=1"
	echo Complete. %APP_COUNT% of %APP_TOTAL% installed
:: cinema 4d
	set APP_PATH=Cinema4D
	set APP_NAME=Cinema4D*.*
	for /f "tokens=*" %%f in ('dir /b %REPO_PATH%\%APP_PATH%\%APP_NAME%') do (set FULL_PATH=%REPO_PATH%\%APP_PATH%\%%f)
	echo Installing %FULL_PATH%...
	START /WAIT %FULL_PATH% --mode unattended
	set /a "APP_COUNT+=1"
	echo Complete. %APP_COUNT% of %APP_TOTAL% installed
:: davinci resolve
	set APP_PATH=DaVinci_Resolve
	set APP_NAME=DaVinci_Resolve*.*
	for /f "tokens=*" %%f in ('dir /b %REPO_PATH%\%APP_PATH%\%APP_NAME%') do (set FULL_PATH=%REPO_PATH%\%APP_PATH%\%%f)
	echo Installing %FULL_PATH%...
	START /WAIT %FULL_PATH% /q /norestart
	set /a "APP_COUNT+=1"
	echo Complete. %APP_COUNT% of %APP_TOTAL% installed
:: deadline
	set APP_PATH=Deadline
	set APP_NAME=DeadlineClient*.*
	for /f "tokens=*" %%f in ('dir /b %REPO_PATH%\%APP_PATH%\%APP_NAME%') do (set FULL_PATH=%REPO_PATH%\%APP_PATH%\%%f)
	echo Installing %FULL_PATH%...
	START /WAIT %FULL_PATH% --mode unattended --licensemode LicenseFree --connectiontype Repository --repositorydir "Z:\Repositories\Deadline\DeadlineRepository10" --launcherstartup true --slavestartup true
	set /a "APP_COUNT+=1"
	echo Complete. %APP_COUNT% of %APP_TOTAL% installed
:: djv
	echo Installing DJV
	START /WAIT %REPO_PATH%\DJV\DJV-1.3.0-win64.exe /S
	set /a "APP_COUNT+=1"
	echo Complete. %APP_COUNT% of %APP_TOTAL% installed
:: sublime
	echo Installing SublimeText...
	START /WAIT %REPO_PATH%\SublimeText\SublimeText_Build_3211_x64_Setup.exe /SILENT /NORESTART
	set /a "APP_COUNT+=1"
	echo Complete. %APP_COUNT% of %APP_TOTAL% installed
:: slack
	echo Installing Slack...
	START /WAIT %REPO_PATH%\Slack\SlackSetup.exe -s
	set /a "APP_COUNT+=1"
	echo Complete. %APP_COUNT% of %APP_TOTAL% installed

:: ==========================
:: ENVONRMENT VARIABLES
:: ==========================
:: cinema 4d
echo "Setting Env Variables for Cinema 4D..."
setx C4D_SCRIPTS_DIR "Z:\Repositories\Cinema 4D\R20\Scripts"
setx g_additionalModulePath "Z:\Repositories\Cinema 4D\Plug-ins"
echo Complete.
:: reshift
echo "Setting Env Variables for Redshift 3D..."
setx REDSHIFT_COREDATAPATH "Z:\Repositories\Redshift\Current"
echo Complete.

:: ==========================
:: SYM LINKS
:: ==========================
:: after effects
echo "Creating Sym Links for After Effects 2019..."
mklink /D "C:\Program Files\Adobe\Adobe After Effects CC 2019\Support Files\Plug-ins\MegaRaid" "Z:\Repositories\After Effects\Plug-ins"
mklink /D "C:\Program Files\Adobe\Adobe After Effects CC 2019\Support Files\Scripts\MegaRaid" "Z:\Repositories\After Effects\Scripts"
echo Complete.

:: ==========================
:: NVIDIA DRIVERS
:: ==========================
:nvidia
	::set /P NVIDIA_CHECK=Install NVIDIA DisplayDriver? This can take a few minutes. [Y/N]?
	if /I "%NVIDIA_CHECK%" EQU "Y" goto :nvidia_Y
	if /I "%NVIDIA_CHECK%" EQU "N" goto :nvidia_N
	goto :nvidia
	:nvidia_Y
		START /WAIT %REPO_PATH%\Nvidia\442.19-desktop-win10-64bit-international-nsd-dch-whql.exe /s
		echo Complete.
	:nvidia_N
		echo NVIDIA Skipped.
		goto nvidia_End
:nvidia_End

:: ==========================
:: EXIT
:: ==========================
goto exit_Script
:exit_Script
	echo Install script finished.
	pause
	exit 0