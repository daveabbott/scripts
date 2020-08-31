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

color 4f
echo ======================================================================================
echo "              __  ___               _   __     __                      __           "
echo "             /  |/  /___ _____     / | / /__  / /__      ______  _____/ /__         "
echo "            / /|_/ / __ \` __ \   /  |/ / _ \/ __/ | /| / / __ \/ ___/ //_/         "
echo "           / /  / / /_/ / /_/ /  / /|  /  __/ /_ | |/ |/ / /_/ / /  / ,<            "
echo "          /_/  /_/\__,_/ .___/  /_/ |_/\___/\__/ |__/|__/\____/_/  /_/|_|           "
echo "                      /_/                                                           "
echo ======================================================================================
:: NOTES
pause
color 0f

echo Mapping network drive(s).
:: ask for credentials
set /P user="Enter Kabbalah username:"
set /P pswd="Enter Kabbalah password:"
:: map drives
net use U: \\kabbalah\Active    /user:%user% %pswd%     /persistent:Yes
net use V: \\kabbalah\Library   /user:%user% %pswd%     /persistent:Yes
:: clear credentials
set "user="
set "pswd="

:: ========================================================================================
::

echo
color 4f
echo ======================================================================================
echo " _       ___           __                      _____      __  __  _                 " 
echo "| |     / (_)___  ____/ /___ _      _______   / ___/___  / /_/ /_(_)___  ____ ______"
echo "| | /| / / / __ \/ __  / __ \ | /| / / ___/   \__ \/ _ \/ __/ __/ / __ \/ __ `/ ___/"
echo "| |/ |/ / / / / / /_/ / /_/ / |/ |/ (__  )   ___/ /  __/ /_/ /_/ / / / / /_/ (__  ) "
echo "|__/|__/_/_/ /_/\__,_/\____/|__/|__/____/   /____/\___/\__/\__/_/_/ /_/\__, /____/  "
echo "                                                                      /____/        "
echo ======================================================================================
:: NOTES
:: This part had to be done via Powershell as CMD wouldn't do it.
pause
color 0f

:: ===================================POWERSHELL :: START==================================

powershell

Rename-Computer -NewName "double-rabbi"

exit
:: ====================================POWERSHELL :: END===================================

:: ========================================================================================
::

echo
color 4f
echo ======================================================================================
echo "    __  __          __      __          ____           __        ____               "
echo "   / / / /___  ____/ /___ _/ /____     /  _/___  _____/ /_____ _/ / /__  __________ "
echo "  / / / / __ \/ __  / __ `/ __/ _ \    / // __ \/ ___/ __/ __ `/ / / _ \/ ___/ ___/ "
echo " / /_/ / /_/ / /_/ / /_/ / /_/  __/  _/ // / / (__  ) /_/ /_/ / / /  __/ /  (__  )  "
echo " \____/ .___/\__,_/\__,_/\__/\___/  /___/_/ /_/____/\__/\__,_/_/_/\___/_/  /____/   "
echo "     /_/                                                                            "
echo ======================================================================================

echo ======================================================================================
echo               Unfortunately not all software can be updated this way.
echo Firefox
echo Slack 
echo ======================================================================================
:: NOTES
:: This part had to be done via Powershell as CMD doesn't use wget.
pause
color 0f

set /P CHECK_UPDATES=Download latest install files? This can take a few minutes. [Y/N]?
    if /I "%CHECK_UPDATES%" EQU "Y" goto :CHECK_UPDATES_Y
    if /I "%CHECK_UPDATES%" EQU "N" goto :CHECK_UPDATES_N
    :CHECK_UPDATES_Y
:: ===================================POWERSHELL :: START==================================

powershell

Set-Variable -Name "REPO_PATH" -Value "V:\Software\Windows"

# firefox
Set-Variable -Name "APP_NAME" -Value "Firefox"
mkdir $REPO_PATH\$APP_NAME
wget 'https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-GB' -OutFile $REPO_PATH\$APP_NAME\$APP_NAME.exe

# slack
Set-Variable -Name "APP_NAME" -Value "Slack"
mkdir $REPO_PATH\$APP_NAME
wget 'https://slack.com/ssb/download-win64' -OutFile $REPO_PATH\$APP_NAME\$APP_NAME.exe

# spotify
Set-Variable -Name "APP_NAME" -Value "spotify"
mkdir $REPO_PATH\$APP_NAME
wget 'https://download.scdn.co/SpotifySetup.exe' -OutFile $REPO_PATH\$APP_NAME\$APP_NAME.exe

exit

:: ====================================POWERSHELL :: END===================================
    :CHECK_UPDATES_N
    echo Nothing to download. Continuing...

:: ========================================================================================
::

echo
color 4f
echo ======================================================================================
echo "                ____           __        ____   ___                                 "
echo "               /  _/___  _____/ /_____ _/ / /  /   |  ____  ____  _____             "
echo "               / // __ \/ ___/ __/ __ `/ / /  / /| | / __ \/ __ \/ ___/             "
echo "             _/ // / / (__  ) /_/ /_/ / / /  / ___ |/ /_/ / /_/ (__  )              "
echo "            /___/_/ /_/____/\__/\__,_/_/_/  /_/  |_/ .___/ .___/____/               "
echo "                                                  /_/   /_/                         "
echo ======================================================================================
echo
echo ======================================================================================
echo       Unfortunately not all software can be installed without user interaction. 
echo               You will be required for the occasinoal button click.
echo           Software that can be installed silently will happen at the end.
echo ======================================================================================
:: NOTES
:: %%f only works when run within a batch script. When testing as single command typed
:: into CMD, use a single %.
pause
color 0f

:: path for apps to install from
set REPO_PATH=V:\Software\Windows
:: reset install counter
set APP_COUNT=0
:: number of apps to install. Set this manually.
set APP_TOTAL=15
:: firefox
    set APP_PATH=Firefox
    set APP_NAME=%APP_PATH%*.*
    for /f "tokens=*" %%f in ('dir /b %REPO_PATH%\%APP_PATH%\%APP_NAME%') do (set FULL_PATH=%REPO_PATH%\%APP_PATH%\%%f)
    START /WAIT %FULL_PATH%
    echo Installing %FULL_PATH%...
    set /a "APP_COUNT+=1"
    echo Complete. %APP_COUNT% of %APP_TOTAL% installed
:: pureref
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
::
echo
color 4f
echo ======================================================================================
echo               Software that can be installed silently will now proceed.
echo                         User action is no longer required.
echo                              May you have a blessed day.
echo ======================================================================================
pause
color 0f
::
:: davinci resolve
    set APP_PATH=DaVinci_Resolve
    set APP_NAME=%APP_PATH%*.*
    for /f "tokens=*" %%f in ('dir /b %REPO_PATH%\%APP_PATH%\%APP_NAME%') do (set FULL_PATH=%REPO_PATH%\%APP_PATH%\%%f)
    echo Installing %FULL_PATH%...
    START /WAIT %FULL_PATH% /q /norestart
    set /a "APP_COUNT+=1"
    echo Complete. %APP_COUNT% of %APP_TOTAL% installed
:: deadline
    set APP_PATH=Deadline
    set APP_NAME=%APP_PATH%Client*.*
    for /f "tokens=*" %%f in ('dir /b %REPO_PATH%\%APP_PATH%\%APP_NAME%') do (set FULL_PATH=%REPO_PATH%\%APP_PATH%\%%f)
    echo Installing %FULL_PATH%...
    START /WAIT %FULL_PATH% --mode unattended --licensemode LicenseFree --connectiontype Remote --proxyrootdir 192.168.69.20:2847 --slavestartup true --launcherdaemon false
    set /a "APP_COUNT+=1"
    echo Complete. %APP_COUNT% of %APP_TOTAL% installed
:: djv
    set APP_PATH=DJV
    set APP_NAME=%APP_PATH%*.*
    for /f "tokens=*" %%f in ('dir /b %REPO_PATH%\%APP_PATH%\%APP_NAME%') do (set FULL_PATH=%REPO_PATH%\%APP_PATH%\%%f)
    echo Installing %FULL_PATH%...
    START /WAIT %FULL_PATH%
    set /a "APP_COUNT+=1"
    echo Complete. %APP_COUNT% of %APP_TOTAL% installed
:: steam
    set APP_PATH=Steam
    set APP_NAME=%APP_PATH%*.*
    for /f "tokens=*" %%f in ('dir /b %REPO_PATH%\%APP_PATH%\%APP_NAME%') do (set FULL_PATH=%REPO_PATH%\%APP_PATH%\%%f)
    echo Installing %FULL_PATH%...
    START /WAIT %FULL_PATH%
    set /a "APP_COUNT+=1"
    echo Complete. %APP_COUNT% of %APP_TOTAL% installed
:: sublime
    set APP_PATH=SublimeText
    set APP_NAME=%APP_PATH%*.*
    for /f "tokens=*" %%f in ('dir /b %REPO_PATH%\%APP_PATH%\%APP_NAME%') do (set FULL_PATH=%REPO_PATH%\%APP_PATH%\%%f)
    echo Installing %FULL_PATH%...
    START /WAIT %FULL_PATH%
    set /a "APP_COUNT+=1"
    echo Complete. %APP_COUNT% of %APP_TOTAL% installed
:: slack
    set APP_PATH=Slack
    set APP_NAME=%APP_PATH%*.*
    for /f "tokens=*" %%f in ('dir /b %REPO_PATH%\%APP_PATH%\%APP_NAME%') do (set FULL_PATH=%REPO_PATH%\%APP_PATH%\%%f)
    echo Installing %FULL_PATH%...
    START /WAIT %FULL_PATH% -s
    set /a "APP_COUNT+=1"
    echo Complete. %APP_COUNT% of %APP_TOTAL% installed
:: spotify
    set APP_PATH=Spotify
    set APP_NAME=%APP_PATH%*.*
    for /f "tokens=*" %%f in ('dir /b %REPO_PATH%\%APP_PATH%\%APP_NAME%') do (set FULL_PATH=%REPO_PATH%\%APP_PATH%\%%f)
    echo Installing %FULL_PATH%...
    START /WAIT %FULL_PATH% -s
    set /a "APP_COUNT+=1"
    echo Complete. %APP_COUNT% of %APP_TOTAL% installed

:: ========================================================================================
::

echo
color 4f 
echo ======================================================================================
echo "             ______              _    __           _       __    __                 "
echo "            / ____/___ _   __   | |  / /___ ______(_)___ _/ /_  / /__  _____        "
echo "           / __/ / __ \ | / /   | | / / __ `/ ___/ / __ `/ __ \/ / _ \/ ___/        "
echo "          / /___/ / / / |/ /    | |/ / /_/ / /  / / /_/ / /_/ / /  __(__  )         "
echo "         /_____/_/ /_/|___/     |___/\__,_/_/  /_/\__,_/_.___/_/\___/____/          "
echo "                                                                                    "
echo ======================================================================================
:: NOTES
:: 
pause
color 0f

:: reshift
rem echo "Setting Env Variables for Redshift 3D..."
rem setx REDSHIFT_COREDATAPATH "Z:\Repositories\Redshift\Current"
rem echo Complete.

:: ========================================================================================
::

echo
color 4f
echo ======================================================================================
echo "         _____                 __          ___         __    _       __             "
echo "        / ___/__  ______ ___  / /_  ____  / (_)____   / /   (_)___  / /_______      "
echo "        \__ \/ / / / __ \__ \/ __ \/ __ \/ / / ___/  / /   / / __ \/ //_/ ___/      "
echo "       ___/ / /_/ / / / / / / /_/ / /_/ / / / /__   / /___/ / / / / ,< (__  )       "
echo "      /____/\__, /_/ /_/ /_/_.___/\____/_/_/\___/  /_____/_/_/ /_/_/|_/____/        "
echo "           /____/                                                                   "
echo ======================================================================================
:: NOTES
:: 
pause
color 0f
:: after effects
rem echo "Creating Sym Links for After Effects 2019..."
rem mklink /D "C:\Program Files\Adobe\Adobe After Effects CC 2019\Support Files\Plug-ins\MegaRaid" "Z:\Repositories\After Effects\Plug-ins"
rem mklink /D "C:\Program Files\Adobe\Adobe After Effects CC 2019\Support Files\Scripts\MegaRaid" "Z:\Repositories\After Effects\Scripts"
rem echo Complete.

:: ========================================================================================
::

echo
color 4f
echo ======================================================================================
echo "           _   __       _     ___          ____       _                             "
echo "          / | / /__  __(_)___/ (_)___ _   / __ \____ (_)   _____  __________        "
echo "         /  |/ /| | / / / __  / / __ \`  / / / / __// / | / / _ \/ ___/ ___/        "
echo "        / /|  / | |/ / / /_/ / / /_/ /  / /_/ / /  / /| |/ /  __/ /  (__  )         "
echo "       /_/ |_/  |___/_/\__,_/_/\__,_/  /_____/_/  /_/ |___/\___/_/  /____/          "
echo "                                                                                    "
echo ======================================================================================
:: NOTES
::
pause
color 0f

rem set /P NVIDIA_CHECK=Install NVIDIA DisplayDriver? This can take a few minutes. [Y/N]?
rem     if /I "%NVIDIA_CHECK%" EQU "Y" goto :NVIDIA_CHECK_Y
rem     if /I "%NVIDIA_CHECK%" EQU "N" goto :NVIDIA_CHECK_N
rem     :NVIDIA_CHECK_Y
rem         echo Nvidia Drivers will be installed after all other software.
rem     :NVIDIA_CHECK_N
rem         echo Nvidia Drivers WILL NOT be installed. Continuing

rem :nvidia
rem     ::set /P NVIDIA_CHECK=Install NVIDIA DisplayDriver? This can take a few minutes. [Y/N]?
rem     if /I "%NVIDIA_CHECK%" EQU "Y" goto :nvidia_Y
rem     if /I "%NVIDIA_CHECK%" EQU "N" goto :nvidia_N
rem     goto :nvidia
rem     :nvidia_Y
rem         START /WAIT %REPO_PATH%\Nvidia\442.19-desktop-win10-64bit-international-nsd-dch-whql.exe /s
rem         echo Complete.
rem     :nvidia_N
rem         echo NVIDIA Skipped.
rem         goto nvidia_End
rem :nvidia_End

:: ========================================================================================
::

echo
color 4f
echo ======================================================================================
echo "                    ___________   ___________ __  ____________  ______              "
echo "                   / ____/  _/ | / /  _/ ___// / / / ____/ __ \/ / / /              "
echo "                  / /_   / //  |/ // / \__ \/ /_/ / __/ / / / / / / /               "
echo "                 / __/ _/ // /|  // / ___/ / __  / /___/ /_/ /_/_/_/                "
echo "                /_/   /___/_/ |_/___//____/_/ /_/_____/_____(_|_|_)                 "
echo "                                                                                    "
echo ======================================================================================
echo
echo ======================================================================================
echo                        Swiggity-swooty it's time for a rebooty.
echo ======================================================================================
pause
exit 0