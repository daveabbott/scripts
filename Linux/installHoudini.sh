#!/bin/sh

REPO_PATH="/mnt/kabbalah/library/Software"

# install houdini
cd /tmp

tar -xvf $REPO_PATH/Houdini/houdini*linux*.tar.gz

HOUDINI="/tmp/houdini*linux*/houdini.install"

$HOUDINI --accept-EULA 2020-05-05

exit 0