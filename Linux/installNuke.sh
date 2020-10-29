#!/bin/sh

REPO_PATH="/mnt/kabbalah/library/Software"

ICON_PATH="/home/davidabbott/.local/share/applications"

NUKE_DEST="/opt/Nuke"

# remove old nuke install
touch $NUKE_DEST	# this step prevents rm from erroring if the dir doesnt exist yet
rm -rf $NUKE_DEST

# install nuke
NUKE_RUN="$REPO_PATH/Nuke/Current/Nuke*.run"
chmod +x $NUKE_RUN
mkdir $NUKE_DEST && cd $_
$NUKE_RUN --accept-foundry-eula

# find nuke binary
NUKE_BIN=$(find -maxdepth 2 -name "Nuke*" -executable -type f)
# find nuke version number
NUKE_VERSION=$(find -maxdepth 1 -name "Nuke*" -type d)

# create shortcuts
cat > $ICON_PATH/Nuke.desktop <<EOF
[Desktop Entry]
Name=Nuke
Exec=env QT_SCALE_FACTOR=1.5 $NUKE_DEST/$NUKE_BIN
Comment=
Terminal=true
MimeType=application/x-nuke;
Icon=$NUKE_DEST/$NUKE_VERSION/plugins/icons/NukeApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

cat > $ICON_PATH/NukeX.desktop <<EOF
[Desktop Entry]
Name=NukeX
Exec=env QT_SCALE_FACTOR=1.5 $NUKE_DEST/$NUKE_BIN --nukex %f
Comment=
Terminal=true
MimeType=application/x-nuke;
Icon=$NUKE_DEST/$NUKE_VERSION/plugins/icons/NukeXApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

cat > $ICON_PATH/NukeStudio.desktop <<EOF
[Desktop Entry]
Name=NukeStudio
Exec=env QT_SCALE_FACTOR=1.5 $NUKE_DEST/$NUKE_BIN --studio %f
Comment=
Terminal=true
MimeType=application/x-nuke;
Icon=$NUKE_DEST/$NUKE_VERSION/plugins/icons/NukeStudioApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

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

exit 0

# .desktop for pre 12.1

# NUKE_RUN="$REPO_PATH/Nuke/Nuke11.3/Nuke-11.3*.run"
# chmod +x $NUKE_RUN
# mkdir /opt/$NUKE11 && cd $_
# unzip $NUKE_RUN

# cat > $ICON_PATH/Nuke$NUKE10.desktop <<EOF
# [Desktop Entry]
# Name=Nuke$NUKE10
# Comment=
# Exec=/opt/Nuke$NUKE10/Nuke10.5 -q
# Terminal=true
# MimeType=application/x-nuke;
# Icon=/opt/Nuke$NUKE10/plugins/icons/NukeApp48.png
# Type=Application
# Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
# EOF

# cat > $ICON_PATH/NukeX$NUKE10.desktop <<EOF
# [Desktop Entry]
# Name=NukeX$NUKE10
# Comment=
# Exec=/opt/Nuke$NUKE10/Nuke10.5 -q --nukex
# Terminal=true
# MimeType=application/x-nuke;
# Icon=/opt/Nuke$NUKE10/plugins/icons/NukeXApp48.png
# Type=Application
# Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
# EOF