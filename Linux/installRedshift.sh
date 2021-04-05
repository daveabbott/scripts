#!/bin/sh

REPO_PATH="/mnt/kabbalah/library/Software"
REDSHIFT_INSTALLER_PATH="$REPO_PATH/Redshift/Current"

REDSHIFT_INSTALLER="$REDSHIFT_INSTALLER_PATH/redshift*.run"

chmod +x $REDSHIFT_INSTALLER

$REDSHIFT_INSTALLER --quiet

exit 0