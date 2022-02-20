#!/bin/sh

#https://www.shellhacks.com/yes-no-bash-script-prompt-confirmation/

OS_VERSION=$(grep VERSION_ID /etc/os-release | tr -d '"')
ALLOWED_VERSION=VERSION_ID="35"

if [[ $OS_VERSION != $ALLOWED_VERSION ]]
then
	echo Incorrect centos version detected.
	echo Detected: $OS_VERSION
	echo Script meant for: $ALLOWED_VERSION
	exho exiting
	exit 0
else
	echo Fedora detected.
	echo Proceeding...
	echo

# set root password
pkexec passwd root

# switch to root
su

# set hostname
echo -e "set-hostname: double-rabbi"
hostnamectl set-hostname double-rabbi

# enable wake on lan
ethtool -s enp6s0 wol g
echo 'ETHTOOL_OPTS="wol g"' > /etc/sysconfig/network-scripts/ifcfg-enp6s0

# uninstall junk
read -p "Remove Cruft? [y/N]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
# remove
	dnf -y remove \
	libreoffice* \
	gnome-weather \
	gnome-weather \
	gnome-boxes \
	rhythmbox \
	cheese \
	gnome-contacts
	#firefox
fi

# install 
	dnf makecache

	dnf -y install \
	dnf-utils \
	kernel-devel \
	kernel-headers \
	dkms

	dnf -y groupinstall "Development Tools"

	dnf -y update

	dnf install \
	https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
	https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

	dnf -y install \
	timeshift \
	p7zip-plugins \
	ffmpeg \
	file-roller
	gnome-tweak-tool


	
	# wireguard
	dnf install -y wireguard-tools

	dnf -y install youtube-dl		# for downloading youtube videos
	# dnf -yinstall ImageMagick		# for converting webp files etc
	dnf -y install OpenImageIO
	dnf install vdpauinfo libva-vdpau-driver libva-utils # GPU acceralted video playback


	# sublime
	rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
	dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
	dnf -y install sublime-text

	#
	# THESE ARE NEEDED FOR PRODUCTION
	#
	# Houdini
	dnf -y install libnsl
	dnf -y install redhat-lsb # for H19
	# Nuke
	dnf -y install libGLU
	dnf -y install python2-numpy # for macbeth chart
	dnf -y install http://mirror.centos.org/centos/8/AppStream/x86_64/os/Packages/GConf2-3.2.6-22.el8.x86_64.rpm # for FLU
	dnf -y install http://mirror.centos.org/centos/8/AppStream/x86_64/os/Packages/compat-openssl10-1.0.2o-3.el8.x86_64.rpm # for Optical Flares
	# PFTrack
	dnf -y install libusb
	# Redshift License Tool
	dnf -y install libpng15

# flatpak
	# add repo
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	# install flatpaks
	flatpak -y install flathub \
	com.bitwarden.desktop \
	org.mozilla.firefox \
	org.mozilla.Thunderbird \
	com.slack.Slack \
	us.zoom.Zoom \
	fr.handbrake.ghb \
	com.makemkv.MakeMKV \
	org.blender.Blender \
	fr.natron.Natron \
	com.rawtherapee.RawTherapee \
	io.github.RodZill4.Material-Maker \
	com.quixel.Bridge \
	org.videolan.VLC \
	com.spotify.Client \
	org.darktable.Darktable \
	net.sourceforge.qtpfsgui.LuminanceHDR \
	org.gnome.Extensions \
	com.rafaelmardojai.Blanket
	
	# folder permisions
	# blender
	flatpak override --filesystem=/mnt/DATUMS/SCRATCH/blender org.blender.Blender
	# quixel
	flatpak override --filesystem=/mnt/kabbalah/repos/megascans com.quixel.Bridge
	# raw therapee
	flatpak override --filesystem=/mnt/kabbalah/active com.rawtherapee.RawTherapee
	flatpak override --filesystem=/mnt/kabbalah/library com.rawtherapee.RawTherapee
	# rdarktable
	flatpak override --filesystem=/mnt/kabbalah/library org.darktable.Darktable

# gnome settings
	# disable hot corners
	gsettings set org.gnome.desktop.interface enable-hot-corners false


# network settings	
	dnf -y install \
	firewalld firewall-config \
	samba-client samba-common \
	cifs-utils \
	autofs \
	nfs-utils
	# firewall settings
	firewall-cmd --zone=public --permanent --add-port=5900/tcp
	firewall-cmd --zone=public --permanent --add-service=vnc-server
	firewall-cmd --zone=public --permanent --add-service=https
	systemctl enable firewalld
	systemctl restart firewalld
	# wireguard
	echo "Adding IP Route for Wireguard"
	echo "192.168.3.0/24 via 192.168.69.30 dev enp6s0" > /etc/sysconfig/network-scripts/route-enp6s0
	echo "192.168.3.0/24 via 192.168.69.30 dev TheInternet" > /etc/sysconfig/network-scripts/route-TheInternet
	echo "192.168.3.0/24 via 192.168.69.30 dev TheInternet_5GHz" > /etc/sysconfig/network-scripts/route-TheInternet_5GHz
	# add kabbalah
	mkdir /mnt/kabbalah
	echo "/mnt/kabbalah /etc/auto.kabbalah --timeout=60" > /etc/auto.master
	echo "active  -fstype=cifs,rw,noperm,vers=3.0,credentials=/etc/.credentials-kabbalah.txt  ://kabbalah/Active/" > /etc/auto.kabbalah
	echo "cloud   -fstype=cifs,rw,noperm,vers=3.0,credentials=/etc/.credentials-kabbalah.txt  ://kabbalah/Cloud/" >> /etc/auto.kabbalah
	echo "library -fstype=cifs,rw,noperm,vers=3.0,credentials=/etc/.credentials-kabbalah.txt  ://kabbalah/Library/" >> /etc/auto.kabbalah
	echo "repos   -fstype=cifs,rw,noperm,vers=3.0,credentials=/etc/.credentials-kabbalah.txt  ://kabbalah/Repositories/" >> /etc/auto.kabbalah
	# add airbag
	#mkdir /mnt/airbag
	#read -p 'Username: ' uservar
	#read -sp 'Password: ' passvar
	#echo "username=$uservar" > /etc/pwd_airbag.txt
	#echo "password=$passvar" >> /etc/pwd_airbag.txt
	#unset uservar passvar
	#echo "/mnt/airbag /etc/auto.airbag --timeout=60" >> /etc/auto.master
	#echo "LDRIVE  -fstype=cifs,rw,noperm,credentials=/etc/pwd_airbag.txt  ://L-ABProjects/LDRIVE" > /etc/auto.airbag
	#echo "SDRIVE  -fstype=cifs,rw,noperm,credentials=/etc/pwd_airbag.txt  ://L-ABProjects/SDRIVE" >> /etc/auto.airbag
	# add pixel
	#mkdir /mnt/pixel
	#read -p 'Username: ' uservar
	#read -sp 'Password: ' passvar
	#echo "username=$uservar" > /etc/pwd_pixel.txt
	#echo "password=$passvar" >> /etc/pwd_pixel.txt
	#unset uservar passvar
	#echo "/mnt/megaraid /etc/auto.pixel --timeout=60" >> /etc/auto.master
	#echo "active  -fstype=afp afp://pixel:osiris23@192.168.1.124/MegaRAID/_ACTIVE" > /etc/auto.pixel

	# autofs
	systemctl enable autofs
	systemctl restart autofs

# nvidia
	dnf install -y dnf-plugins-core
	
	dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
	dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

	dnf update

	dnf install -y akmod-nvidia
	dnf install -y xorg-x11-drv-nvidia-cuda

exit 0