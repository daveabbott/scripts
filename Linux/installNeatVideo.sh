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
$REPO_PATH/NeatVideo/NeatVideo*.run --mode console

exit 0