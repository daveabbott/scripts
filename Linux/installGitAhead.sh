#!/bin/sh

REPO_PATH="/mnt/kabbalah/library/Software"

# get OS name
if type lsb_release >/dev/null 2>&1 ; then
   DISTRO=$(lsb_release -i -s)
elif [ -e /etc/os-release ] ; then
   DISTRO=$(awk -F= '$1 == "ID" {print $2}' /etc/os-release)
elif [ -e /etc/some-other-release-file ] ; then
   DISTRO=$(ihavenfihowtohandleotherhypotheticalreleasefiles)
fi

DISTRO=$(printf '%s\n' "$DISTRO" | LC_ALL=C tr '[:upper:]' '[:lower:]')

case "$DISTRO" in
	centos*) ICON_PATH="/home/davidabbott/.local/share/applications" ;;
	fedora*) ICON_PATH="/usr/share/applications" ;;
esac

# remove old nuke install
cd /opt/

$REPO_PATH/GitAhead/GitAhead*.sh -y

cat > $ICON_PATH/GitAhead.desktop <<EOF
[Desktop Entry]
Name=GitAhead
Comment=
Exec="/opt/GitAhead/GitAhead"
Terminal=false
Icon=/opt/GitAhead/Resources/GitAhead.iconset/icon_64x64@2x.png
Type=Application
Categories=Development;
EOF

exit 0