#!/bin/sh

# Ask for JOBNAME
echo "Enter JOBNAME. No spaces!"
read JOBNAME

# Ask for JOBCODE
echo "Enter JOBCODE. No spaces!"
read JOBCODE

# Go to default project path
cd /mnt/kabbalah/active

# Create project folder and change to directory
mkdir $(date +"%y%m%d")_$JOBNAME && cd $_

# Print Working Directory as JOBPATH
JOBPATH=$PWD

# Create metadata file
cat > ./.metadata << EOF
JOBNAME=$JOBNAME
JOBPATH=$JOBPATH
JOBCODE=$JOBCODE
JOBDATE=$(date +"%y%m%d")
EOF

# Create subfolders
mkdir -p ./_output/{breakdown,toGrade,toClient,wip}
mkdir -p ./_input/{fromClient/$(date +"%y%m%d"),fromGrade/$(date +"%y%m%d")}
mkdir -p ./_cache/{houdini,nuke/{EXR/{denoise,smartVectors},JPG/{denoise}},redshift}
mkdir -p ./_renders/{ae,houdini,mocha,nuke,resolve}
mkdir -p ./assets/{audio,images,fonts,graphics,hdri,models,maps,video,reference,rushes,xml}
mkdir -p ./project/{meshroom,pftrack,photoshop,premiere,resolve}
mkdir -p ./shots/"$JOBCODE"_{A..E}

# create shot folder within each sequence
cd ./shots
for dir in */ ; do
	SEQUENCE=${dir%*/}
	cd $dir
	mkdir -p ./"$SEQUENCE"_{00..20}0/{ae,blender,data/{cameras,tracking,scripts},houdini,mocha,nuke,photoshop}

	# Create empty placeholders
	for dir in */ ; do
    	SHOTNAME=${dir%*/}
		# after effects
    	touch ./$SHOTNAME/ae/"$SHOTNAME"_v01.aep;
		# blender
    	touch ./$SHOTNAME/blender/"$SHOTNAME"_v01.blend;
		# houdini
    	touch ./$SHOTNAME/houdini/"$SHOTNAME"_v01.hiplc;
		# nuke
   		touch ./$SHOTNAME/nuke/"$SHOTNAME"_comp_v01.nk;
   	done
   	cd ./..
done

exit 0

# Tree
JOBDATE: Date project commenced
JOBNAME: Name of project
JOBCODE: Three letter acronym derived from name.

JOBDATE_JOBNAME
	_in
		fromClient
			[date]
		fromGrade
			[date]
	_out
		breakdown
		wip
		toGrade
			[date]
		toClient
			[date]
	_cache									# _cache: Should only contain files that can be deleted once project is complete, and easily regenerated if needed.
		nuke
			EXR								# EXR: Denoised plates, smartVectors etc.
				JOBCODE_010
			JPG								# JPG: Denoised plates for mocha or pftrack.
				JOBCODE_010
		houdini
		redshift
	_renders								# _renders: Rendered files that take a long time to generate. Can be deleted if emergency space is needed.
		ae
			JOBCODE_010
		houdini
			JOBCODE_010
		mocha
			JOBCODE_010
		nuke
			JOBCODE_010
		resolve								# resolve: Rushes/selects transcoded to linear EXR. Subfoldered in Resolve by TIMELINE/VIDEOLAYER/SEQUENCENUMBER.
	assets									# assets: Files here are either provided by client or are unique to this project in some way.
		audio
		images
		fonts
		graphics
		maps
		hdri
		video
		reference
		rushes								# rushes: preferably stored offline.
		xml
	project									# project: Global project files that influence multiple shots or are an assembly edit.
		meshroom
		pftrack
		photoshop
		premiere
		resolve
	shots									# shots: Contains shot folders. 000 is used for any RnD.
		JOBCODE_010
			ae
			blender
			data							# data: Cameras, tracking data, placeholder geo, point clouds, etc.
			houdini
			mocha
			nuke
			photoshop