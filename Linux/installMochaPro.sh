#!/bin/sh

REPO_PATH="/mnt/kabbalah/library/Software"

# run installer
dnf install -y $REPO_PATH/Mocha/MochaPro2020*.rpm

# set mimetype
cat > /usr/share/mime/packages/project-mocha-script.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>

<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/mochapro">
    <comment>nuke script</comment>
    <glob pattern="*.mocha"/>
  </mime-type>
</mime-info>
EOF

exit 0
