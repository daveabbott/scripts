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

echo -e "set-hostname: double-rabbi"
hostnamectl set-hostname double-rabbi

read -p "Setup yum? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
# remove
	yum remove -y gnome-weather
	yum remove -y boxes
	yum remove -y rhythmbox
	yum remove -y empathy
	yum remove -y cheese
	yum remove -y ekiga
	yum remove -y evolution
	yum remove -y gnome-contacts
	yum remove -y firefox 		# centos firefox doesn't update very quickly. Reinstalling from Flathub below.
# install
	yum makecache
	yum install -y epel-release yum-utils
	yum install -y deltarpm
	yum groupinstall -y "Development Tools"
	yum install -y kernel-devel
	yum install -y kernel-headers
	yum install -y dkms
# nvidia
	yum-config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-rhel7.repo
	yum -y install nvidia-driver-latest-dkms nvidia-settings cuda
	export PATH=/usr/local/cuda-10.2/bin:/usr/local/cuda-10.2/NsightCompute-2019.1${PATH:+:${PATH}}
	echo "blacklist nouveau" > /etc/modprobe.d/blacklist.conf
	dracut --force
	grub2-mkconfig -o /boot/grub2/grub.cfg
# update
	yum update -y
# repos
	yum localinstall -y --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
		sed -i '/gpgcheck=1/a exclude=*nvidia* *cuda*' /etc/yum.repos.d/rpmfusion-free*.repo
	yum localinstall -y --nogpgcheck https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm
		sed -i '/gpgcheck=1/a exclude=*nvidia* *cuda*' /etc/yum.repos.d/rpmfusion-nonfree*.repo

	yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm

	yum install -y ffmpeg compat-ffmpeg28				# compat allows firefox to play mp4
	yum install -y timeshift
	yum install -y kmod-hfs kmod-hfsplus hfsplus-tools	# allows reading of mac drives. slow to install.
	yum install -y qt-x11.x86_64						# required for Redshift Licencing Tool
	yum install -y libpng12								# required for Redshift Licencing Tool
	yum install -y redhat-lsb-core						# required for Redshift
	yum install -y nodejs								# required for Sublime CSS/HTML tidying
	yum install -y alien rpmrebuild						# allows for .deb to be rebuilt as .rpm
	yum install -y exfat-utils fuse-exfat				# enables read support for exfat
# balena etcher
	yum-config-manager --add-repo=https://balena.io/etcher/static/etcher-rpm.repo
	yum install -y balena-etcher-electron
# turbovnc
	rpm --import https://www.turbovnc.org/key/VGL-GPG-KEY
	yum-config-manager --add-repo=https://turbovnc.org/pmwiki/uploads/Downloads/TurboVNC.repo
	yum install -y turbovnc
# virtualgl
	rpm --import https://www.virtualgl.org/key/VGL-GPG-KEY
	yum-config-manager --add-repo=https://virtualgl.org/pmwiki/uploads/Downloads/VirtualGL.repo
	yum install -y VirtualGL
# sublime
	rpm --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
	yum-config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
	yum install -y sublime-text
	yum install -y sublime-merge
# wireguard
	yum install -y yum-plugin-elrepo
	yum install -y kmod-wireguard wireguard-tools
# virtualbox
	yum-config-manager --add-repo=https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo
	yum install -y VirtualBox-6.0.x86_64
# flatpaks
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak install -y flathub com.bitwarden.desktop
	flatpak install -y flathub org.mozilla.firefox
	flatpak install -y flathub org.mozilla.Thunderbird
	flatpak install -y flathub com.slack.Slack
	flatpak install -y flathub us.zoom.Zoom
	flatpak install -y flathub fr.handbrake.ghb
	flatpak install -y flathub com.makemkv.MakeMKV
	flatpak install -y flathub org.videolan.VLC
		# add HiDPI support to app shortcut
		sed -i '/Exec=/c Exec=env QT_AUTO_SCREEN_SCALE_FACTOR=0 /usr/bin/flatpak run --branch=stable --arch=x86_64 --command=/app/bin/vlc --file-forwarding org.videolan.VLC --started-from-file @@u %U @@' /var/lib/flatpak/exports/share/applications/org.videolan.VLC.desktop
	flatpak install -y flathub com.spotify.Client
		# add HiDPI support to app shortcut
		sed -i '/Exec=/c Exec=/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=spotify --file-forwarding com.spotify.Client --force-device-scale-factor=1.5 @@u %U @@' /var/lib/flatpak/exports/share/applications/com.spotify.Client.desktop
	flatpak install -y flathub org.blender.Blender 											# blender
		flatpak override --filesystem=/mnt/DATUMS/SCRATCH/blender org.blender.Blender
	flatpak install -y flathub fr.natron.Natron												# nuke clone
	flatpak install -y flathub com.rawtherapee.RawTherapee									# raw image processor
	flatpak install -y flathub io.github.RodZill4.Material-Maker							# Substance Designer clone
	flatpak install -y flathuborg.gimp.GIMP													# gimp
	flatpak install -y flathub org.dust3d.dust3d											# 3d modelling tool
	flatpak install flathub com.valvesoftware.Steam
		# add extra folder permisions
		flatpak override --filesystem=/mnt/ATHENAEUM/Steam com.valvesoftware.Steam
		flatpak override --filesystem=/opt com.valvesoftware.Steam
		flatpak override --filesystem=/home/davidabbott/.local/share/applications com.valvesoftware.Steam
	flatpak install -y flathub org.DolphinEmu.dolphin-emu
	flatpak install -y flathub org.libretro.RetroArch
	flatpak install -y flathub com.github.tchx84.Flatseal
	#flatpak install -y flathub com.uploadedlobster.peek
	#flatpak install -y flathub org.gnome.OCRFeeder
	flatpak install -y flathub com.quixel.Bridge
		# add extra folder permisions
		flatpak override --filesystem=/mnt/kabbalah/library/Stock\ Assets/Megascans\ Library com.quixel.Bridge
fi

read -p "Change System Settings? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	#yum install -y firewalld firewall-config
	#yum install -y samba-client samba-common cifs-utils autofs nfs-utils
# gnome settings
	rm -r /usr/share/gnome-shell/extensions/window-list@gnome-shell-extensions.gcampax.github.com # this deletes the bottom windows-style task bar
	firefox https://extensions.gnome.org/extension/517/caffeine/
	firefox https://extensions.gnome.org/extension/1160/dash-to-panel/
# firewall settings
	firewall-cmd --zone=public --permanent --add-port=5900/tcp
	firewall-cmd --zone=public --permanent --add-service=vnc-server
	firewall-cmd --zone=public --permanent --add-service=https
	systemctl enable firewalld
# wireguard
	echo "192.168.3.0/24 via 192.168.69.30 dev enp6s0" > /etc/sysconfig/network-scripts/route-enp6s0
	echo "192.168.3.0/24 via 192.168.69.30 dev TheInternet" > /etc/sysconfig/network-scripts/route-TheInternet
	echo "192.168.3.0/24 via 192.168.69.30 dev TheInternet_5GHz" > /etc/sysconfig/network-scripts/route-TheInternet_5GHz
# mount: kabbalah
	mkdir /mnt/kabbalah
	echo "/mnt/kabbalah /etc/auto.kabbalah --timeout=60" > /etc/auto.master
	echo "active  -fstype=nfs  192.168.69.20:/volume1/Active" > /etc/auto.kabbalah
	echo "cloud  -fstype=nfs  192.168.69.20:/volume1/Cloud" >> /etc/auto.kabbalah
	echo "library  -fstype=nfs  192.168.69.20:/volume1/Library" >> /etc/auto.kabbalah
	echo "media  -fstype=nfs  192.168.69.20:/volume1/Media" >> /etc/auto.kabbalah
	echo "temp  -fstype=nfs  192.168.69.20:/volume1/Temp" >> /etc/auto.kabbalah
# mount: airbag
	mkdir /mnt/airbag
	read -p 'Username: ' uservar
	read -sp 'Password: ' passvar
	echo "username=$uservar" > /etc/pwd_airbag.txt
	echo "password=$passvar" >> /etc/pwd_airbag.txt
	unset uservar passvar
	echo "/mnt/airbag /etc/auto.airbag --timeout=60" >> /etc/auto.master
	echo "LDRIVE  -fstype=cifs,rw,noperm,credentials=/etc/pwd_airbag.txt  ://L-ABProjects/LDRIVE" > /etc/auto.airbag
	echo "SDRIVE  -fstype=cifs,rw,noperm,credentials=/etc/pwd_airbag.txt  ://L-ABProjects/SDRIVE" >> /etc/auto.airbag
# mount: pixel
	mkdir /mnt/pixel
	read -p 'Username: ' uservar
	read -sp 'Password: ' passvar
	echo "username=$uservar" > /etc/pwd_pixel.txt
	echo "password=$passvar" >> /etc/pwd_pixel.txt
	unset uservar passvar
	echo "/mnt/pixel /etc/auto.pixel --timeout=60" >> /etc/auto.master
	echo "MegaRAID  -fstype=cifs,rw,noperm,credentials=/etc/pwd_pixel.txt  ://MegaRAID/MegaRAID" > /etc/auto.pixel
# mount: autofs
	systemctl enable autofs
	systemctl restart autofs
fi

read -p "Run Installers? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
# # #
REPO_PATH="/mnt/kabbalah/library/Software"
# # #
# PFtrack
	yum install -y $REPO_PATH/PixelFarm/pftrack-2016*.rpm
	yum install -y $REPO_PATH/PixelFarm/pfmanager-2018*.rpm
# DJV
	yum install -y /mnt/kabbalah/library/Software/Linux/DJV/DJV*.rpm
# Deadline
	$REPO_PATH/Thinkbox/DeadlineClient*.run --mode unattended --licensemode LicenseFree --connectiontype Remote --proxyrootdir 192.168.69.20:2847 --slavestartup true --launcherdaemon false
# DaVinci Resolve
	# echo -------------------------------------------------
	# echo  open new Terminal window as a user and run this
	# echo -------------------------------------------------
	# echo $REPO_PATH/Blackmagic/DaVinci_Resolve_Studio_*.run -iy
	# read -p "Press [Enter] key to continue..."
# GitAhead
	cd /opt/
	chmod +x $REPO_PATH/GitAhead/GitAhead*.sh
	$REPO_PATH/GitAhead/GitAhead*.sh -y
# Houdini
	# cd /tmp
	# tar -xvf /mnt/kabbalah/library/Software/Houdini/houdini*linux*.tar.gz
	# HOUDINI="/tmp/houdini*linux*/houdini.install"
	# $HOUDINI --accept-EULA
# Mocha
	yum install -y $REPO_PATH/ImagineerSystems/MochaPro*.rpm
# NeatVideo
	$REPO_PATH/NeatVideo/NeatVideo*.run --mode console
# NoMachine
	yum install -y @$REPO_PATH/NoMachine/
# Nuke
	# version control
	NUKE10="Nuke10.5v4"
	NUKE11="Nuke11.3v3"
	NUKE12="Nuke12.2v2"

	NUKEX10="NukeX10.5v4"
	NUKEX11="NukeX11.3v3"
	NUKEX12="NukeX12.2v2"
# Nuke10
	NUKE_RUN="$REPO_PATH/Nuke/Nuke-10.5/Nuke-10.5*.run"
	chmod +x $NUKE_RUN
	mkdir /opt/$NUKE10 && cd $_
	unzip $NUKE_RUN
# Nuke11
	NUKE_RUN="$REPO_PATH/Nuke/Nuke11.3/Nuke-11.3*.run"
	chmod +x $NUKE_RUN
	mkdir /opt/$NUKE11 && cd $_
	unzip $NUKE_RUN
# Nuke12
	NUKE_RUN="$REPO_PATH/Nuke/Nuke12.1/Nuke-12.1*.run"
	chmod +x $NUKE_RUN
	cd /opt
	$NUKE_RUN --accept-foundry-eula
# Redshift
	$REPO_PATH/Redshift/redshift_v2*.run --quiet

## Licenses
---------------------
# Nuke
	RLM="/usr/local/foundry/RLM/"
	mkdir -p $RLM
	echo "HOST 192.168.69.2 any 4101" > $RLM/wifi.lic
	echo "HOST 192.168.3.2 any 4101" > $RLM/wireguard.lic
	echo "HOST 192.168.69.4 any 4101" > $RLM/ethernet.lic

# MakeMKV
cat > /home/davidabbott/.MakeMKV/settings.conf<<EOF
#
# MakeMKV settings file, written by MakeMKV v1.15.1 linux(x64-release)
#

app_DestinationDir = ""
app_InterfaceLanguage = "eng"
app_Java = ""
app_Key = "T-UWwbYn781f1gjZcH5NOsJkGgWHnUkQsr2IduoSJ8sssNXOqclsWhowNWTclkBjHIMH"
app_PreferredLanguage = "eng"
app_ccextractor = ""
sdf_Stop = ""
EOF

## Icons
---------------------
ICON_PATH='/home/davidabbott/.local/share/applications'

# DaVinci
cat > /usr/share/applications/com.blackmagicdesign.resolve.desktop<<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=DaVinci Resolve
GenericName=DaVinci Resolve
Comment=Revolutionary new tools for editing, visual effects, color correction and professional audio post production, all in a single application!
Path=/opt/resolve/
Exec=env QT_DEVICE_PIXEL_RATIO=2 /opt/resolve/bin/resolve %U
Terminal=false
MimeType=application/x-resolveproj;
Icon=/opt/resolve/graphics/DV_Resolve.png
StartupNotify=true
Name[en_US]=DaVinci Resolve
EOF

# Firefox
cat > $ICON_PATH/firefox.desktop <<EOF
[Desktop Entry]
Name=Firefox
Comment=
Exec="/opt/firefox/firefox"
Terminal=false
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Type=Application
Categories=GTK;WebBrowser;Network;
EOF

# GitAhead
cat > $ICON_PATH/GitAhead.desktop <<EOF
[Desktop Entry]
Name=GitAhead
Comment=
Exec="/opt/GitAhead/GitAhead"
Terminal=false
Icon=/opt/GitAhead/Resources/GitAhead.iconset/icon_64x64@2x.png
Type=Application
Categories=Development;
EOF

# Nuke 10
cat > $ICON_PATH/$NUKE10.desktop <<EOF
[Desktop Entry]
Name=$NUKE10
Comment=
Exec=/opt/$NUKE10/Nuke10.5 -q
Terminal=true
MimeType=application/x-nuke;
Icon=/opt/$NUKE10/plugins/icons/NukeApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

cat > $ICON_PATH/$NUKEX10.desktop <<EOF
[Desktop Entry]
Name=$NUKEX10
Comment=
Exec=/opt/$NUKE10/Nuke10.5 -q --nukex
Terminal=true
MimeType=application/x-nuke;
Icon=/opt/$NUKE10/plugins/icons/NukeXApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

# Nuke 12
cat > $ICON_PATH/$NUKE12.desktop <<EOF
[Desktop Entry]
Name=$NUKE12
Exec=env QT_SCALE_FACTOR=1.5 /opt/$NUKE12/Nuke12.2
Comment=
Terminal=true
MimeType=application/x-nuke;
Icon=/opt/$NUKE12/plugins/icons/NukeApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

cat > $ICON_PATH/$NUKEX12.desktop <<EOF
[Desktop Entry]
Name=$NUKEX12
Exec=env QT_SCALE_FACTOR=1.5 /opt/$NUKE12/Nuke12.2 --nukex %f
Comment=
Terminal=true
MimeType=application/x-nuke;
Icon=/opt/$NUKE12/plugins/icons/NukeXApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

# Mocha
cat > $ICON_PATH/mochapro2020.desktop << EOF
[Desktop Entry]
Name=Mocha Pro 2020
Comment=
Exec=/usr/bin/mochapro2020
Terminal=true
MimeType=application/mochapro;
Icon=/opt/isl/MochaPro2020/resources/mochaproIcon.ico
Type=Application
Categories=Graphics;
EOF

# # Unreal
# cat > $ICON_PATH/Unreal.desktop << EOF
# [Desktop Entry]
# Name=Unreal Editor
# Comment=
# Exec=/mnt/ATHENAUEM/GitHub/UnrealEngine/Engine/Binaries/Linux/Unreal/UE4Editor
# Terminal=true
# MimeType=application/unreal;
# Icon=/mnt/ATHENAEUM/GitHub/UnrealEngine/Engine/Source/Programs/PrereqInstaller/Resources/Setup.ico
# Type=Application
# Categories=Graphics;
# EOF

## Mimetypes
---------------------
# Mocha
cat > /usr/share/mime/packages/project-mocha-script.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>

<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/mochapro">
    <comment>nuke script</comment>
    <glob pattern="*.mocha"/>
  </mime-type>
</mime-info>
EOF

# Nuke
cat > /usr/share/mime/packages/project-nuke-script.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>

<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-nuke">
    <comment>nuke script</comment>
    <glob pattern="*.nk"/>
  </mime-type>
</mime-info>
EOF

# Update Mime
	update-mime-database /usr/share/mime
fi

# GitHub
# houdini
# git clone https://github.com/qLab/qLib.git
# git clone https://github.com/toadstorm/MOPS.git
# git clone https://github.com/sideeffects/GameDevelopmentToolset.git

# Environment variables
# houdini
# HOUDINI_ENV="/home/davidabbott/houdini18.0/houdini.env"
# cat > $HOUDINI_ENV << EOF
# HOUDINI_NO_SPLASH = 1
# HOUDINI_DSO_ERROR = 2

# DEADLINE = $HOME/Thinkbox/Deadline10/submitters/HoudiniSubmitter

# GAMEDEV = $HOME/GitHub/GameDevelopmentToolset

# MOPS = $HOME/GitHub/MOPS

# QLIB = $HOME/GitHub/qLib
# QOTL = $QLIB/otls

# REDSHIFT = /usr/redshift/bin
# REDSHIFT4HOUDINI = /usr/redshift/redshift4houdini/${HOUDINI_VERSION}

# HOUDINI_OTLSCAN_PATH = $QOTL/base:$QOTL/future:$QOTL/experimental:$HOUDINI_OTLSCAN_PATH:&
# HOUDINI_PATH = $HOUDINI_PATH:$DEADLINE:$GAMEDEV:$MOPS:$QLIB:$REDSHIFT4HOUDINI:&
# PATH = $GAMEDEV/bin:$REDSHIFT:$PATH
# HOUDINI_MENU_PATH = $HOUDINI_MENU_PATH:$DEADLINE:&
# EOF

exit 0