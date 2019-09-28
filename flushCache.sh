#!/bin/sh

# Removes all files within the directory. Preserves the directory itself.

function flush {
	if [ -d "$1" ]
	then
		rm -r "$1/"* 2> /dev/null
		echo "	flushed - $1/"
	else
		echo "	doesn't exist - $1"
	fi
}

echo
echo ADOBE
echo ----------------
flush "$HOME/Library/Caches/Adobe/After Effects"
flush "$HOME/Library/Caches/Adobe/Adobe Media Encoder"
flush "$HOME/Library/Caches/Adobe Camera Raw"
flush "$HOME/Library/Application Support/Adobe/Common"
flush "/Volumes/RAID_SSD/SCRATCH/adobe"

echo
echo MARI
echo ----------------
flush "/Volumes/RAID_SSD/SCRATCH/Mari"

echo
echo MOCHA
echo ----------------
flush "/var/tmp/MoTemp"
flush "/var/tmp/MoTempBCC"
flush "/Volumes/RAID_SSD/SCRATCH/mocha"

echo
echo MODO
echo ----------------
flush "$HOME/Library/Application Support/Luxology/AutoSave"
flush "/Volumes/RAID_SSD/SCRATCH/modo"

echo
echo NUKE
echo ----------------
flush "/var/tmp/nuke-u501"
flush "/Volumes/RAID_SSD/SCRATCH/nuke/BlockCache"
flush "/Volumes/RAID_SSD/SCRATCH/nuke/ViewerCache"
flush "/Volumes/RAID_SSD/SCRATCH/nuke/tileCache"
flush "/Volumes/RAID_SSD/SCRATCH/nuke/flipbook"
flush "/Volumes/RAID_SSD/SCRATCH/nuke/ofxplugincache"
	## LINUX
flush "/var/tmp/nuke-u1000"


echo
echo RESOLVE
echo ----------------
flush "$HOME/Movies/CacheClip"
flush "/Volumes/RAID_SSD/SCRATCH/resolve"

echo
echo FLUSH COMPLETE
echo ----------------
echo

exit