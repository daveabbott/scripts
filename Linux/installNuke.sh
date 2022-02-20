#!/bin/sh

REPO_PATH="/mnt/kabbalah/library/Software"
NUKE_PATH="$REPO_PATH/Nuke/Current/"

NUKE_DEST="/opt/Nuke"

# get OS name
if type lsb_release >/dev/null 2>&1 ; then
   DISTRO=$(lsb_release -i -s)
elif [ -e /etc/os-release ] ; then
   DISTRO=$(awk -F= '$1 == "ID" {print $2}' /etc/os-release)
elif [ -e /etc/some-other-release-file ] ; then
   DISTRO=$(ihavenfihowtohandleotherhypotheticalreleasefiles)
fi

# make distro lower case
DISTRO=$(printf '%s\n' "$DISTRO" | LC_ALL=C tr '[:upper:]' '[:lower:]')

# set icon path
 case "$DISTRO" in
 	centos*) ICON_PATH="/home/davidabbott/.local/share/applications" ;; # this can't be $HOME as script must run as root
 	fedora*) ICON_PATH="/usr/share/applications" ;;
 esac

# remove old nuke installs
touch $NUKE_DEST	# this step prevents rm from erroring if the dir doesnt exist yet
rm -rf $NUKE_DEST
mkdir $NUKE_DEST

# install nuke(s)
cd $NUKE_PATH
for f in *.run ; do # this will ignore any non run files. useful if mac installers live in same directory
	NUKE_INSTALLER=${f%*/}
	chmod +x $NUKE_PATH/$NUKE_INSTALLER
	cd $NUKE_DEST
	$NUKE_PATH/$NUKE_INSTALLER --accept-foundry-eula
	cd $NUKE_PATH
done

# remove icons
rm -rf $ICON_PATH/Nuke*.desktop

# create icons
# check for installed versions
cd $NUKE_DEST
for dir in */ ; do
	NUKE_VER=${dir%*/}
	
	# decend into sub folder and find binary
	cd ./$NUKE_VER
	NUKE_BIN=$(find -maxdepth 2 -name "Nuke*" -executable -type f)

	# split release and version number off of dir
	delimiter="Nuke"
	s=$NUKE_VER$delimiter
	array=();
	while [[ $s ]]; do
    	array+=( "${s%%"$delimiter"*}" );
    	s=${s#*"$delimiter"};
	done;
	declare -a array

	# print version number
	echo Nuke version ${array[1]} installed

	# return up a level
	cd ./..

# nuke-standard
cat > $ICON_PATH/Nuke${array[1]}.desktop <<EOF
[Desktop Entry]
Name=Nuke${array[1]}
Exec=env QT_SCALE_FACTOR=1.5 $NUKE_DEST/$NUKE_VER/$NUKE_BIN
Comment=
Terminal=true
MimeType=application/x-nuke;
Icon=$NUKE_DEST/$NUKE_VER/plugins/icons/NukeApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

# nuke-x
cat > $ICON_PATH/NukeX${array[1]}.desktop <<EOF
[Desktop Entry]
Name=NukeX${array[1]}
Exec=env QT_SCALE_FACTOR=1.5 $NUKE_DEST/$NUKE_VER/$NUKE_BIN --nukex %f
Comment=
Terminal=true
MimeType=application/x-nuke;
Icon=$NUKE_DEST/$NUKE_VER/plugins/icons/NukeXApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

# nuke-studio
cat > $ICON_PATH/NukeStudio${array[1]}.desktop <<EOF
[Desktop Entry]
Name=NukeStudio${array[1]}
Exec=env QT_SCALE_FACTOR=1.5 $NUKE_DEST/$NUKE_VER/$NUKE_BIN --studio %f
Comment=
Terminal=true
MimeType=application/x-nuke;
Icon=$NUKE_DEST/$NUKE_VER/plugins/icons/NukeStudioApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

done

# set mimetype for .nk
cat > /usr/share/mime/packages/project-nuke-script.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>

<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-nuke">
    <comment>nuke script</comment>
    <glob pattern="*.nk"/>
  </mime-type>
</mime-info>
EOF

# update mimetype
update-mime-database /usr/share/mime

# create license files
RLM="/usr/local/foundry/RLM/"
mkdir -p $RLM
echo "HOST 192.168.69.2 any 4101" > $RLM/wifi.lic
echo "HOST 192.168.3.2 any 4101" > $RLM/wireguard.lic
echo "HOST 192.168.69.4 any 4101" > $RLM/ethernet.lic

# install FLU



# make the dir for the tools to copy into. -p creates all dirs in the chain
mkdir -p /usr/local/foundry/LicensingTools8.0/bin/RLM

dnf install $NUKE_PATH/../FoundryLicensingUtility*.rpm

# copy these files and then run the FLU and start the server
sudo cp /opt/FoundryLicensingUtility/bin/rlm.foundry /usr/local/foundry/LicensingTools8.0/bin/RLM/rlm.foundry
sudo cp /opt/FoundryLicensingUtility/bin/rlmutil /usr/local/foundry/LicensingTools8.0/bin/RLM/rlmutil
sudo cp /opt/FoundryLicensingUtility/bin/foundry.set /usr/local/foundry/LicensingTools8.0/bin/RLM/foundry.set
sudo cp /opt/FoundryLicensingUtility/bin/foundryrlmserver /etc/init.d/foundryrlmserver

chkconfig --add foundryrlmserver

exit 0



# Nuke 10.5 on Fedora
#NUKE10="/mnt/kabbalah/library/Software/Linux/Foundry/Nuke-10.5*.run"
#cp $NUKE10 /opt
#chmod +x /opt/Nuke-10.5*.run
#mkdir /opt/Nuke10.5v4 && cd $_
#unzip /opt/Nuke-10.5*.run
#cp /mnt/kabbalah/library/Software/Linux/Foundry/Nuke10.5/libGLU.so.1.3.1 /lib64
#cp /mnt/kabbalah/library/Software/Linux/Foundry/Nuke10.5/libidn.so.11 /opt/Nuke10.5v4