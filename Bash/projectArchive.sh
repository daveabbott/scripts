#!/bin/sh

PROJECTPATH=$PWD

if [ -f ".metadata" ]
then
    echo ".metadata found. Proceeding";
else
    echo "No metadata found. Exiting."
    exit 0
fi

# Delete empty files and folders
echo
read -p "Delete empty files and folders? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	find . -type d -empty -delete
    find . -type f -empty -delete
fi

# Delete temp and cache files
echo
read -p "Delete temp and cache files? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    find . -type d -name '_cache' -delete
    find . -type f -name '*.tmp' -delete
fi

# Compress shot folders
echo
read -p "Compress project files? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then

cd ./shots
function compressProjects {
    echo "compressing $1 projects"
    for sequence in */; do

        echo entering "$sequence"
        cd $sequence

        for shot in */; do
            if [ -d "${shot%*/}/$1" ]
            then
                7z a -mx=9 ../../_archive/"$sequence""${shot%*/}"/$1 "${shot%*/}"/$1;
            else
                echo "$1 doesn't exist";
            fi
        done

        cd ./..
    done
}

compressProjects "ae"
compressProjects "blender"
compressProjects "data"
compressProjects "houdini"
compressProjects "mocha"
compressProjects "nuke"

cd ./..
fi

# Update metadata file
cd $PROJECTPATH
echo "DATEARCHIVED=$(date +"%y%m%d")" >> .metadata