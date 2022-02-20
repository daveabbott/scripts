#!/bin/sh

REPO_PATH="/mnt/kabbalah/library/Software"

cd /tmp

tar -xvf $REPO_PATH/NeatVideo/NeatVideo*.tgz

NEAT="/tmp/NeatVideo*.run"

$NEAT --mode console

exit 0