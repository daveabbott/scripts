#!/bin/sh

REPO_PATH="/mnt/kabbalah/library/Software"
REDSHIFT_INSTALLER_PATH="$REPO_PATH/Redshift"

REDSHIFT_INSTALLER="$REDSHIFT_INSTALLER_PATH/redshift*.run"

chmod +x $REDSHIFT_INSTALLER

$REDSHIFT_INSTALLER --quiet

/usr/redshift/bin/redshiftLicensingTool

exit 0