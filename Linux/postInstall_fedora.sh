#!/bin/sh

#https://www.shellhacks.com/yes-no-bash-script-prompt-confirmation/

OS_VERSION=$(grep VERSION_ID /etc/os-release | tr -d '"')
ALLOWED_VERSION=VERSION_ID="33"

if [[ $OS_VERSION != $ALLOWED_VERSION ]]
then
	echo Incorrect centos version detected.
	echo Detected: $OS_VERSION
	echo Script meant for: $ALLOWED_VERSION
	exho exiting
	exit 0
else
	echo Fedora 33 detected.
	echo Proceeding...
	echo

# set root password
pkexec passwd root

# switch to root
su

# set hostname
echo -e "set-hostname: double-rabbi"
hostnamectl set-hostname double-rabbi

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
	gnome-contacts \
	firefox
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

	dnf -y install \
	fedora-workstation-repositories \
	gnome-tweak-tool \
	timeshift \
	p7zip-plugins
	
	# cinnamon
	dnf -y install \
	cinnamon \
	nemo-fileroller

	# THESE ARE NEEDED FOR PRODUCTION
	dnf -y install libnsl			# needed for Houdini
	dnf -y install libGLU			# needed for Nuke
	dnf -y install libusb			# needed for PFTrack
	dnf -y install linpng15			# needed for redshift license
	
	# GitHub CLI
	sudo -y dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
	sudo -y dnf install gh

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
	com.sublimetext.three \
	org.darktable.Darktable
	
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

# network settings	
	dnf -y install firewalld firewall-config
	dnf -y install samba-client samba-common cifs-utils autofs nfs-utils
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
	echo "active  -fstype=nfs  192.168.69.20:/volume1/Active" > /etc/auto.kabbalah
	echo "cloud  -fstype=nfs  192.168.69.20:/volume1/Cloud" >> /etc/auto.kabbalah
	echo "library  -fstype=nfs  192.168.69.20:/volume1/Library" >> /etc/auto.kabbalah
	echo "repos  -fstype=nfs  192.168.69.20:/volume1/Repositories" >> /etc/auto.kabbalah
	# add airbag
	mkdir /mnt/airbag
	read -p 'Username: ' uservar
	read -sp 'Password: ' passvar
	echo "username=$uservar" > /etc/pwd_airbag.txt
	echo "password=$passvar" >> /etc/pwd_airbag.txt
	unset uservar passvar
	echo "/mnt/airbag /etc/auto.airbag --timeout=60" >> /etc/auto.master
	echo "LDRIVE  -fstype=cifs,rw,noperm,credentials=/etc/pwd_airbag.txt  ://L-ABProjects/LDRIVE" > /etc/auto.airbag
	echo "SDRIVE  -fstype=cifs,rw,noperm,credentials=/etc/pwd_airbag.txt  ://L-ABProjects/SDRIVE" >> /etc/auto.airbag
	# add pixel
	mkdir /mnt/pixel
	read -p 'Username: ' uservar
	read -sp 'Password: ' passvar
	echo "username=$uservar" > /etc/pwd_pixel.txt
	echo "password=$passvar" >> /etc/pwd_pixel.txt
	unset uservar passvar
	echo "/mnt/pixel /etc/auto.pixel --timeout=60" >> /etc/auto.master
	echo "MegaRAID  -fstype=cifs,rw,noperm,credentials=/etc/pwd_pixel.txt  ://MegaRAID/MegaRAID" > /etc/auto.pixel

	# autofs
	systemctl enable autofs
	systemctl restart autofs

# nvidia
	chmod +x /mnt/kabbalah/library/Software/_drivers/Nvidia/NVIDIA*.run
	
	dnf -y install \
	acpid \
	dkms \
	gcc \
	kernel-devel \
	kernel-headers \
	libglvnd-glx \
	libglvnd-opengl \
	libglvnd-devel \
	make \
	pkgconfig

	dnf -y config-manager --add-repo \
	https://developer.download.nvidia.com/compute/cuda/repos/fedora33/x86_64/cuda-fedora33.repo

	dnf clean all

	dnf -y module install nvidia-driver:latest-dkms

	dnf -y install cuda

# wireguard
#	dnf copr enable jdoss/wireguard -y
#	dnf install -y wireguard-dkms wireguard-tools

exit 0