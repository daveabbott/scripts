#!/bin/sh

REPO_PATH="/mnt/kabbalah/library/Software"
REDSHIFT_PATH="$REPO_PATH/Redshift/Current/"

REDSHIFT_INSTALLER="$REDSHIFT_PATH/redshift*.run"

$REDSHIFT_INSTALLER --quiet

exit 0