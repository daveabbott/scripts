#!/bin/bash

# Converts filepaths between Linux, Mac and Windows depending on where I'm working.

# export STUDIO="pixel"
source ~/.bash_profile

# TEST PATHS
# Z:\ACTIVE\KMART - August Living 18\Projects\05 Shots
# /Volumes/MegaRAID/ACTIVE/KMART - August Living 18/Projects/05 Shots
# /mnt/MegaRAID/active/KMART - August Living 18/Projects/05 Shots

echo Converting path for location: $STUDIO
echo ----------------

if [ "$STUDIO" == "home" ]; then
	winPath="-----------"
	macPath="~/Resilio Sync"
	linPath="/mnt/kabbalah/active"
elif [ "$STUDIO" == "airbag" ]; then
	winPath="L:\ACTIVE"
	macPath="/Volumes/L/ACTIVE"
	linPath="/mnt/airbag/L/active"
elif [ "$STUDIO" == "pixel" ]; then
	winPath="Z:\ACTIVE"
	macPath="/Volumes/MegaRAID/ACTIVE"
	linPath="/mnt/MegaRAID/active"
else
	echo $STUDIO unknown location
	exit 1
fi

function convertPath {
	if [ "$(uname)" == "Darwin" ]; then								# Get clipboard contents
		cb=`pbpaste`
	elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
		cb=`xclip -o`
	fi
	echo input: "$cb"												# print contents as input
	if [[ "$cb" == /V* ]]; then										# convert from mac
		LIN=${cb/"$macPath"/"$linPath"}
	MAC=$cb
	WIN=${cb/"$macPath"/"$winPath"}
	elif [[ "$cb" == /m* ]]; then									# convert from lin
		MAC=${cb/"$linPath"/"$macPath"}
		LIN=$cb
		WIN=${cb/"$linPath"/"$winPath"}
	elif [[ "$cb" == *:* ]]; then									# convert from win
		LIN=${cb/"$winPath"/"$linPath"}
		MAC=${cb/"$winPath"/"$macPath"}
		WIN=$cb
	else
		LIN="invalid path"
		MAC="invalid path"
		WIN="invalid path"
	fi
	LIN=${LIN//\\//}												# flip slashes for win
	MAC=${MAC//\\//}
	WIN=${WIN////\\}
	echo #blank
	echo Lin: "$LIN"												# print conversion
	echo Mac: "$MAC"
	echo Win: "$WIN"
}

convertPath