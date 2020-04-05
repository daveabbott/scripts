#!/bin/bash

# macOS

# Launches apps sequentially with a delay inbetween each one.
# Helps machine be more responsive while still loading startup apps.


function launch {
	echo "attempting to launch $1"
    if [ -d "/Applications/$1.app" ]		#check if app is installed
    then
    	sleep 30							#time in seconds before next app launch
        open -a "$1" -jg --hide				#launch app and set to background
    else
        echo "$1 doesn't exist"
    fi
}

launch "Amphetamine"
launch "Dropbox"
#launch "Resilio Sync"
launch "Thinkbox/Deadline10/DeadlineLauncher10"
#launch "1Password"

echo "delayLaunch finished"

exit

