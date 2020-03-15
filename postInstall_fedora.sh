#!/bin/sh

echo -e "set-hostname: double-rabbi"
hostnamectl set-hostname double-rabbi

read -p "Install Basics? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	dnf makecache
	dnf install -y dnf-utils
	dnf install -y deltarpm
	dnf groupinstall -y "Development Tools"
	dnf install -y kernel-devel kernel-headers
	dnf install -y dkms

	dnf install -y fedora-workstation-repositories
	dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
	dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

	dnf install -y timeshift
	dnf install -y alacarte						# allow easy changing of app shortcuts
	dnf install -y piper						# mouse configurator
	dnf install -y handbrake-gui
	dnf install -y libGLU						#needed for Nuke10
	dnf install -y libusb       				#needed for PFTrack

	rpm --import https://www.turbovnc.org/key/VGL-GPG-KEY
	dnf config-manager --add-repo=https://turbovnc.org/pmwiki/uploads/Downloads/TurboVNC.repo
	dnf install -y turbovnc

	rpm --import https://www.virtualgl.org/key/VGL-GPG-KEY
	dnf config-manager --add-repo=https://virtualgl.org/pmwiki/uploads/Downloads/VirtualGL.repo
	dnf install -y VirtualGL 

	dnf install -y steam --enablerepo=rpmfusion-nonfree-steam
	
	dnf copr enable jdoss/wireguard
	dnf install -y wireguard-dkms wireguard-tools

	dnf config-manager --add-repo=https://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo
	dnf install -y VirtualBox-6.0.x86_64

	dnf update

	#dnf install -y gcc make acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig

fi

read -p "Install Network? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	dnf install -y firewalld firewall-config
	dnf install -y samba-client samba-common cifs-utils autofs nfs-utils

	# firewall settings
	firewall-cmd --zone=public --permanent --add-port=5900/tcp
	firewall-cmd --zone=public --permanent --add-service=vnc-server
	firewall-cmd --zone=public --permanent --add-service=https
	systemctl enable firewalld

	# wireguard
	echo "Adding IP Route for Wireguard"
	echo "192.168.3.0/24 via 192.168.69.30 dev enp6s0" > /etc/sysconfig/network-scripts/route-enp6s0
	echo "192.168.3.0/24 via 192.168.69.30 dev TheInternet" > /etc/sysconfig/network-scripts/route-TheInternet
	echo "192.168.3.0/24 via 192.168.69.30 dev TheInternet_5GHz" > /etc/sysconfig/network-scripts/route-TheInternet_5GHz

	# auto mount
	mkdir /mnt/kabbalah
	echo "/mnt/kabbalah /etc/auto.kabbalah --timeout=60" > /etc/auto.master
	echo "active  -fstype=nfs  192.168.69.20:/volume1/Active" > /etc/auto.kabbalah
	echo "library  -fstype=nfs  192.168.69.20:/volume1/Library" >> /etc/auto.kabbalah
	echo "media  -fstype=nfs  192.168.69.20:/volume1/Media" >> /etc/auto.kabbalah
	echo "temp  -fstype=nfs  192.168.69.20:/volume1/Temp" >> /etc/auto.kabbalah

	mkdir /mnt/airbag
	read -p 'Username: ' uservar
	read -sp 'Password: ' passvar
	echo "username=$uservar" > /etc/pwd_airbag.txt
	echo "password=$passvar" >> /etc/pwd_airbag.txt
	unset uservar passvar
	echo "/mnt/airbag /etc/auto.airbag --timeout=60" >> /etc/auto.master
	echo "LDRIVE  -fstype=cifs,rw,noperm,credentials=/etc/pwd_airbag.txt  ://L-ABProjects/LDRIVE" > /etc/auto.airbag
	echo "SDRIVE  -fstype=cifs,rw,noperm,credentials=/etc/pwd_airbag.txt  ://L-ABProjects/SDRIVE" >> /etc/auto.airbag

	mkdir /mnt/pixel
	read -p 'Username: ' uservar
	read -sp 'Password: ' passvar
	echo "username=$uservar" > /etc/pwd_pixel.txt
	echo "password=$passvar" >> /etc/pwd_pixel.txt
	unset uservar passvar
	echo "/mnt/pixel /etc/auto.pixel --timeout=60" >> /etc/auto.master
	echo "MegaRAID  -fstype=cifs,rw,noperm,credentials=/etc/pwd_pixel.txt  ://MegaRAID/Active" > /etc/auto.pixel

	systemctl enable autofs
	systemctl restart autofs
fi

read -p "Install Licences? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	mkdir -p /usr/local/foundry/RLM/
	RLM="/usr/local/foundry/RLM/"
	echo "HOST 192.168.69.2 any 4101" > $RLM/wifi.lic
	echo "HOST 192.168.3.2 any 4101" > $RLM/wireguard.lic
	echo "HOST 192.168.69.4 any 4101" > $RLM/ethernet.lic
fi

read -p "Install Snaps? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	dnf -y install snapd
	ln -s /var/lib/snapd/snap /snap
	systemctl enable snapd
	systemctl start snapd
	echo "pausing for 5 seconds while snapd starts"
	sleep 5
	snap install snap-store
	sudo snap install bitwarden
	sudo snap install blender --classic
	sudo snap install slack --classic
	sudo snap install sublime-text --classic
	sudo snap install vlc
fi

read -p "Run Installers? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	rpm -i '/mnt/kabbalah/library/Software/Linux/PixelFarm/pftrack-2016.24.29-1.x86_64.rpm'
	rpm -i '/mnt/kabbalah/library/Software/Linux/PixelFarm/pfmanager-2018.13.28-1.x86_64.rpm'
	rpm -i '/mnt/kabbalah/library/Software/Linux/DJV/DJV*.rpm'

	/mnt/kabbalah/library/Software/Linux/Thinkbox/Deadline-*-linux-installers/DeadlineClient*.run --mode unattended --licensemode LicenseFree --connectiontype Remote --proxyrootdir 192.168.69.20:2847 --slavestartup true --launcherdaemon false
	
	echo "/mnt/kabbalah/library/Software/Linux/Blackmagic/DaVinci_Resolve_Studio_*.run -y" > /home/davidabbott/Desktop/INSTALL.txt



# GitAhead
cd /opt/
/mnt/kabbalah/library/Software/Linux/GitAhead/GitAhead*.sh

# NeatVideo
/mnt/kabbalah/library/Software/Linux/NeatVideo/NeatVideo*.run --mode console

# NUKE 10.5
NUKESOURCE = /mnt/kabbalah/library/Software/Linux/Foundry/
NUKEDESTIN = /opt/Nuke10.5v4

mkdir $NUKEDESTIN
cd $NUKEDESTIN
unzip $NUKESOURCE/Nuke10.5v4-linux-x86-release-64-installer.run
cp $NUKESOURCE/Nuke10.5/libidn.so.11 $NUKEDESTIN

cat > /usr/share/applications/Nuke10.5v4 <<-EOF
[Desktop Entry]
Name=Nuke10.5v4
Comment=
Exec="/opt/Nuke10.5v4/Nuke10.5" -b  %f
Terminal=false
MimeType=application/x-nuke;
Icon=/opt/Nuke10.5v4/plugins/icons/NukeApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

cat > /usr/share/applications/Nuke10.5v4 <<-EOF
[Desktop Entry]
Name=NukeX10.5v4
Comment=
Exec="/opt/Nuke10.5v4/Nuke10.5" -b --nukex %f
Terminal=false
MimeType=application/x-nuke;
Icon=/opt/Nuke10.5v4/plugins/icons/NukeXApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

fi

read -p "Install Nvidia? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	sudo dnf install akmod-nvidia
	sudo dnf install xorg-x11-drv-nvidia-cuda
fi

read -p "Download Themes? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	mkdir -p /github/ && cd $_
	git clone https://github.com/vinceliuice/Tela-icon-theme.git
	git clone https://github.com/linuxmint/cinnamon-spices-themes.git
fi

exit 0