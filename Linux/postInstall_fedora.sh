#!/bin/sh

#https://www.shellhacks.com/yes-no-bash-script-prompt-confirmation/

echo -e "set-hostname: double-rabbi"
hostnamectl set-hostname double-rabbi

read -p "Remove Cruft? [y/N]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	dnf remove -y exaile
	dnf remove -y xawtv
	dnf remove -y pidgin
	dnf remove -y parole
	dnf remove -y xfburn
	dnf remove -y shotwell
	dnf remove -y libreoffice*
	dnf remove -y hexchat
fi

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

	dnf update -y

	dnf install -y fedora-workstation-repositories
	dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
	dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

	dnf install -y timeshift
	dnf install -y alacarte						# allow easy changing of app shortcuts
	dnf install -y piper						# mouse configurator
	dnf install -y handbrake-gui
    dnf install -y blender
    dnf install -y vlc
    dnf install -y ffmpeg

	dnf install -y libGLU						# needed for Nuke10.5
	dnf install -y libusb       				# needed for PFTrack
# turbovnc
	rpm --import https://www.turbovnc.org/key/VGL-GPG-KEY
	dnf config-manager --add-repo=https://turbovnc.org/pmwiki/uploads/Downloads/TurboVNC.repo
	dnf install -y turbovnc
# virtualgl
	rpm --import https://www.virtualgl.org/key/VGL-GPG-KEY
	dnf config-manager --add-repo=https://virtualgl.org/pmwiki/uploads/Downloads/VirtualGL.repo
	dnf install -y VirtualGL 
# spotify
	dnf config-manager --add-repo=https://negativo17.org/repos/fedora-spotify.repo
	dnf install -y spotify-client
# steam
	dnf install -y steam --enablerepo=rpmfusion-nonfree-steam
# sublime
    rpm --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
    dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
    dnf install -y sublime-text
# wireguard
	dnf copr enable jdoss/wireguard -y
	dnf install -y wireguard-dkms wireguard-tools
# virtualbox
	dnf config-manager --add-repo=https://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo
	dnf install -y VirtualBox-6.0.x86_64
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
# kabbalah
	mkdir /mnt/kabbalah
	echo "/mnt/kabbalah /etc/auto.kabbalah --timeout=60" > /etc/auto.master
	echo "active  -fstype=nfs  192.168.69.20:/volume1/Active" > /etc/auto.kabbalah
	echo "cloud  -fstype=nfs  192.168.69.20:/volume1/Cloud" >> /etc/auto.kabbalah
	echo "library  -fstype=nfs  192.168.69.20:/volume1/Library" >> /etc/auto.kabbalah
	echo "media  -fstype=nfs  192.168.69.20:/volume1/Media" >> /etc/auto.kabbalah
	echo "temp  -fstype=nfs  192.168.69.20:/volume1/Temp" >> /etc/auto.kabbalah
# airbag
	mkdir /mnt/airbag
	read -p 'Username: ' uservar
	read -sp 'Password: ' passvar
	echo "username=$uservar" > /etc/pwd_airbag.txt
	echo "password=$passvar" >> /etc/pwd_airbag.txt
	unset uservar passvar
	echo "/mnt/airbag /etc/auto.airbag --timeout=60" >> /etc/auto.master
	echo "LDRIVE  -fstype=cifs,rw,noperm,credentials=/etc/pwd_airbag.txt  ://L-ABProjects/LDRIVE" > /etc/auto.airbag
	echo "SDRIVE  -fstype=cifs,rw,noperm,credentials=/etc/pwd_airbag.txt  ://L-ABProjects/SDRIVE" >> /etc/auto.airbag
# pixel
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
fi

read -p "Run Installers? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
# PFtrack
	dnf install -y '/mnt/kabbalah/library/Software/Linux/PixelFarm/pftrack-2016.24.29-1.x86_64.rpm'
	dnf install -y '/mnt/kabbalah/library/Software/Linux/PixelFarm/pfmanager-2018.13.28-1.x86_64.rpm'
# DJV
	dnf install -y '/mnt/kabbalah/library/Software/Linux/DJV/DJV*.rpm'
# Deadline
	/mnt/kabbalah/library/Software/Linux/Thinkbox/DeadlineClient*.run --mode unattended --licensemode LicenseFree --connectiontype Remote --proxyrootdir 192.168.69.20:2847 --slavestartup true --launcherdaemon false
#DaVinci Resolve
	# this needs to be installed as a user and not as root.
	echo "/mnt/kabbalah/library/Software/Linux/Blackmagic/DaVinci_Resolve_Studio_*.run -iy" > /install_Resolve.sh
# GitAhead
	cd /opt/
	/mnt/kabbalah/library/Software/Linux/GitAhead/GitAhead*.sh -y

cat > /usr/share/applications/GitAhead.desktop <<EOF
[Desktop Entry]
Name=GitAhead
Comment=
Exec="/opt/GitAhead/GitAhead"
Terminal=false
Icon=/opt/GitAhead/Resources/GitAhead.iconset/icon_64x64@2x.png
Type=Application
Categories=Development;
EOF

# Mocha
	dnf install -y '/mnt/kabbalah/library/Software/Linux/ImagineerSystems/MochaPro2020*.rpm'

cat > /usr/share/applications/mochapro2020.desktop << EOF
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

cat > /usr/share/mime/packages/project-mocha-script.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>

<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/mochapro">
    <comment>nuke script</comment>
    <glob pattern="*.mocha"/>
  </mime-type>
</mime-info>
EOF

# NeatVideo
	/mnt/kabbalah/library/Software/Linux/NeatVideo/NeatVideo*.run --mode console -y

# Nuke10.5
	NUKE10="/mnt/kabbalah/library/Software/Linux/Foundry/Nuke-10.5*.run"
	cp $NUKE10 /opt
	chmod +x /opt/Nuke-10.5*.run
	mkdir /opt/Nuke10.5v4 && cd $_
	unzip /opt/Nuke10.5*.run
	cp /mnt/kabbalah/library/Software/Linux/Foundry/Nuke10.5/libidn.so.11 /opt/Nuke10.5v4
	cp /mnt/kabbalah/library/Software/Linux/Foundry/Nuke10.5/libGLU.so.1.3.1 /lib64

cat > /usr/share/applications/Nuke10.5v4.desktop <<EOF
[Desktop Entry]
Name=Nuke10.5v4
Comment=
Exec=/opt/Nuke10.5v4/Nuke10.5 -q
Terminal=true
MimeType=application/x-nuke;
Icon=/opt/Nuke10.5v4/plugins/icons/NukeApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

cat > /usr/share/applications/NukeX10.5v4.desktop <<EOF
[Desktop Entry]
Name=NukeX10.5v4
Comment=
Exec=/opt/Nuke10.5v4/Nuke10.5 -q --nukex
Terminal=true
MimeType=application/x-nuke;
Icon=/opt/Nuke10.5v4/plugins/icons/NukeXApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

# Nuke12.0
	NUKE12="/mnt/kabbalah/library/Software/Linux/Foundry/Nuke-12.0*.run"
	chmod +x $NUKE12
	cd /opt
	$NUKE12 --accept-foundry-eula

cat > /usr/share/applications/Nuke12.0v5.desktop <<EOF
[Desktop Entry]
Name=Nuke12.0v5
Exec=/opt/Nuke12.0v5/Nuke12.0 -q
Comment=
Terminal=true
MimeType=application/x-nuke;
Icon=/opt/Nuke12.0v5/plugins/icons/NukeApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

cat > /usr/share/applications/NukeX12.0v5.desktop <<EOF
[Desktop Entry]
Name=NukeX12.0v5
Exec=/opt/Nuke12.0v5/Nuke12.0 --nukex -q
Comment=
Terminal=true
MimeType=application/x-nuke;
Icon=/opt/Nuke12.0v5/plugins/icons/NukeXApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

# Nuke12.1
	NUKE12="/mnt/kabbalah/library/Software/Linux/Foundry/Nuke-12.1*.run"
	chmod +x $NUKE12
	cd /opt
	$NUKE12 --accept-foundry-eula

cat > /usr/share/applications/Nuke12.1v1.desktop <<EOF
[Desktop Entry]
Name=Nuke12.1v1
Exec=env QT_SCALE_FACTOR=1.5 /opt/Nuke12.1v1/Nuke12.1 -q
Comment=
Terminal=true
MimeType=application/x-nuke;
Icon=/opt/Nuke12.1v1/plugins/icons/NukeApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

cat > /usr/share/applications/NukeX12.1v1.desktop <<EOF
[Desktop Entry]
Name=NukeX12.1v1
Exec=env QT_SCALE_FACTOR=1.5 /opt/Nuke12.1v1/Nuke12.1 -q --nukex
Comment=
Terminal=true
MimeType=application/x-nuke;
Icon=/opt/Nuke12.1v1/plugins/icons/NukeXApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

# create mime types
cat > /usr/share/mime/packages/project-nuke-script.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>

<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-nuke">
    <comment>nuke script</comment>
    <glob pattern="*.nk"/>
  </mime-type>
</mime-info>
EOF
# Redshift
	sudo /mnt/kabbalah/library/Software/Linux/Redshift/redshift_v2.6.5*.run --quiet
# Slack
	dnf install -y '/mnt/kabbalah/library/Software/Linux/Slack/slack*.rpm'
# Zoom
	RPM_ZOOM="/mnt/kabbalah/library/Software/Linux/Zoom/zoom_x86_64.rpm"
	wget -q https://zoom.us/client/latest/zoom_x86_64.rpm -O $RPM_ZOOM
	dnf install -y $RPM_ZOOM

# update mime
	update-mime-database /usr/share/mime

fi

read -p "Install Licences? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then

# Nuke
	mkdir -p /usr/local/foundry/RLM/
	RLM="/usr/local/foundry/RLM/"
	echo "HOST 192.168.69.2 any 4101" > $RLM/wifi.lic
	echo "HOST 192.168.3.2 any 4101" > $RLM/wireguard.lic
	echo "HOST 192.168.69.4 any 4101" > $RLM/ethernet.lic
fi

read -p "Download Themes? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	mkdir -p /github/ && cd $_
	git clone https://github.com/vinceliuice/Tela-icon-theme.git
	git clone https://github.com/linuxmint/cinnamon-spices-themes.git
fi

read -p "Install Nvidia? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	sudo dnf install -y akmod-nvidia
	sudo dnf install -y xorg-x11-drv-nvidia-cuda
fi

exit 0
