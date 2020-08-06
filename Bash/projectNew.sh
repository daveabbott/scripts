echo "Enter JOBNAME"
read JOBNAME

echo "Enter JOBCODE"
read JOBCODE

# Go to default project path
cd /mnt/kabbalah/active

# Create project folder and enter
mkdir $(date +"%y%m%d")_$JOBNAME && cd $_

# Store project folder path
JOBPATH=$PWD

# Create subfolders
mkdir -p ./_output/{breakdown,wip,masters}
mkdir -p ./_cache/{nuke/{EXR,JPG},houdini,redshift}
mkdir -p ./_renders/{ae,houdini,nuke,resolve}
mkdir -p ./assets/{audio,images,graphics,models,maps,video/{rushes,graded},reference}
mkdir -p ./project/{edit,pftrack,resolve}
mkdir -p ./shots/"$JOBCODE"_{00..20}0/{ae,blender,data,houdini,mocha,nuke}

# Create empty placeholders
cd ./shots
for dir in */ ; do
    SHOTNAME=${dir%*/}
    touch ./$SHOTNAME/ae/$SHOTNAME_v01.aep;
    touch ./$SHOTNAME/blender/$SHOTNAME_v01.blend;
    touch ./$SHOTNAME/houdini/$SHOTNAME_v01.hiplc;
    touch ./$SHOTNAME/nuke/$SHOTNAME_v01.nk;
done

# Create metadata file
cd $JOBPATH
cat > ./.metadata << EOF
JOB NAME: $JOBNAME
JOB PATH: $JOBPATH
DATE COMMENCED: $(date +"%y-%m-%d")
EOF