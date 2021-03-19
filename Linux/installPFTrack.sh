#!/bin/sh

REPO_PATH="/mnt/kabbalah/library/Software"
PFTRACK_PATH="$REPO_PATH/PixelFarm/"

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

# set distro installer
 case "$DISTRO" in
 	centos*) INST=yum ;;
 	fedora*) INST=dnf ;;
 esac

# install
$INST install -y '$PFTRACK_PATH/pftrack-2016.24.29-1.x86_64.rpm'
$INST install -y '$PFTRACK_PATH/pfmanager-2018.13.28-1.x86_64.rpm'

exit 0