PROJECTPATH=$PWD

if [ -f ".metadata" ]
then
    echo ".metadata found. Proceeding";
else
    exit 0
fi

# Delete empty files and folders
read -p "Delete empty files and folders? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	find . -type d -empty -delete
    find . -type f -empty -delete
fi

# Delete temp and cache files
read -p "Delete temp and cache files? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    find . -type d -name '_cache' -delete
    find . -type f -name '*.tmp' -delete
fi

# Compress known shot folders
cd ./shots

function compressProjects {
    echo "compressing $1 projects"
    for folder in */; do
        if [ -d "${folder%*/}/$1" ]
        then
            7z a -mx=9 "${folder%*/}"/$1 "${folder%*/}"/$1;
        else
            echo "$1 doesn't exist";
        fi
    done
}

compressProjects "ae"
compressProjects "blender"
compressProjects "data"
compressProjects "houdini"
compressProjects "mocha"
compressProjects "nuke"

# Update metadata file
cd $PROJECTPATH
echo "DATE ARCHIVED: $(date +"%y-%m-%d")" >> .metadata