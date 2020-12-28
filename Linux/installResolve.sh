#!/bin/sh

REPO_PATH="/mnt/kabbalah/library/Software"

cd /tmp

ARCHIVE="$REPO_PATH/DaVinci_Resolve/DaVinci_Resolve_Studio*Linux.zip"
unzip $ARCHIVE

RESOLVE="/tmp/DaVinci_Resolve_Studio_*.run"
$RESOLVE -iy

exit 0