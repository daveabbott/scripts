#!/bin/sh

REPO_PATH="/mnt/kabbalah/library/Software"

# run installer
$REPO_PATH/Deadline/DeadlineClient*.run --mode unattended --licensemode LicenseFree --connectiontype Remote --proxyrootdir 192.168.69.20:2847 --slavestartup true --launcherdaemon false

exit 0
