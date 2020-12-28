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
    find . -path '*/@eaDir*' -delete
    find . -type f -name '.DS_Store' -delete

fi

# Compress folders
echo
read -p "Compress project files? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then

# input
cd ./_input
for dir in *; do
	cd $dir
		for datedfolder in *; do
			7z a -mx=3 $PROJECTPATH/_archive/_input/$dir/$datedfolder.7z $datedfolder;
		done
	cd ./..
done
cd ./..

# project
cd ./project
for dir in *; do
	7z a -mx=9 $PROJECTPATH/_archive/project/$dir.7z $dir;
done
cd ./..

# shots
cd ./shots
for sequence in *; do
    cd $sequence
	for shot in *; do
		cd $shot
			for subfolder in *; do
                7z a -mx=9 $PROJECTPATH/_archive/shots/$sequence/$shot/$subfolder.7z $subfolder;
            done
        cd ./..
        done
    cd ./..
done
cd ./..

fi

# Update metadata file
cd $PROJECTPATH
echo "DATEARCHIVED=$(date +"%y%m%d")" >> .metadata