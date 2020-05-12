#!/bin/sh

OS_VERSION=$(grep VERSION_ID /etc/os-release | tr -d '"')
ALLOWED_VERSION=VERSION_ID="7"

if [[ $OS_VERSION != $ALLOWED_VERSION ]]
then
	echo Incorrect centos version detected.
	echo Detected: $OS_VERSION
	echo Script meant for: $ALLOWED_VERSION
	exho exiting
	exit 0
else
	echo CentOS 7 detected.
	echo Proceeding...
	echo
fi

FIREFOX_LOCAL="/mnt/kabbalah/library/Software/Linux/Firefox/firefox.tar.bz2"
FIREFOX_REMOTE="https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US"
wget -q $FIREFOX_REMOTE -O $FIREFOX_LOCAL
rm -r /opt/firefox
cd /opt
tar xvjf $FIREFOX_LOCAL
sudo ln -s /opt/firefox/firefox /usr/bin/firefox

exit 0