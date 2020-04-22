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
	yum makecache
	yum install -y epel-release yum-utils
	#yum install -y deltarpm
	yum groupinstall -y "Development Tools"
	#yum groupinstall -y "Fonts"
	yum install -y kernel-devel
	yum install -y kernel-headers
	yum install -y dkms

	yum-config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-rhel7.repo
	yum -y install nvidia-driver-latest-dkms nvidia settings cuda
	export PATH=/usr/local/cuda-10.2/bin:/usr/local/cuda-10.2/NsightCompute-2019.1${PATH:+:${PATH}}
	echo "blacklist nouveau" > /etc/modprobe.d/blacklist.conf
	dracut --force
	grub2-mkconfig -o /boot/grub2/grub.cfg

	yum update -y

	yum localinstall -y --nogpgcheck https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm
	sed -i '/gpgcheck=1/a exclude=*nvidia* *cuda*' /etc/yum.repos.d/rpmfusion-nonfree*.repo
	yum localinstall -y --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
	sed -i '/gpgcheck=1/a exclude=*nvidia* *cuda* *vlc* x264-libs x265-libs' /etc/yum.repos.d/rpmfusion-free*.repo

	yum-config-manager --add-repo=https://negativo17.org/repos/epel-multimedia.repo
	sed -i '/repo_gpgcheck=0/a exclude=*nvidia* *cuda*' /etc/yum.repos.d/epel-multimedia.repo

	yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm

	yum install -y vlc
	#yum install -y file-roller
	#yum install -y wget
	yum install -y ffmpeg
	yum install -y handbrake-gui
	#yum install -y nano
	#yum install -y gnome-system-monitor
	#yum install -y eog
	#yum install -y gnome-tweak-tool
	yum install -y timeshift
	yum install -y piper								# mouse configurator
	yum install -y kmod-hfs kmod-hfsplus hfsplus-tools	# allows reading of mac drives

	yum install -y qt-x11.x86_64						# required for Redshift Licencing Tool
	yum install -y libpng12								# required for Redshift Licencing Tool
	yum install -y redhat-lsb-core						# required for Redshift
	yum install -y qt5-qtbase-devel						# required for Mocha and VLC

# turbovnc
	rpm --import https://www.turbovnc.org/key/VGL-GPG-KEY
	yum-config-manager --add-repo=https://turbovnc.org/pmwiki/uploads/Downloads/TurboVNC.repo
	yum install -y turbovnc
# virtualgl
	rpm --import https://www.virtualgl.org/key/VGL-GPG-KEY
	yum-config-manager --add-repo=https://virtualgl.org/pmwiki/uploads/Downloads/VirtualGL.repo
	yum install -y VirtualGL
# spotify
	yum-config-manager --add-repo=https://negativo17.org/repos/fedora-spotify.repo
	yum install -y spotify-client
# steam
	rpm --import https://negativo17.org/repos/RPM-GPG-KEY-slaanesh
	yum-config-manager --add-repo=https://negativo17.org/repos/epel-steam.repo
# sublime
	rpm --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
	yum-config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
	yum install -y sublime-text
# wireguard
	yum install -y yum-plugin-elrepo
	yum install -y kmod-wireguard wireguard-tools
# virtualbox
	yum-config-manager --add-repo=https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo
	yum install -y VirtualBox-6.0.x86_64
# makemkv
	yum install -y makemkv libdvdcss
	echo "T-UWwbYn781f1gjZcH5NOsJkGgWHnUkQsr2IduoSJ8sssNXOqclsWhowNWTclkBjHIMH" > /makemkv-betakey.txt
fi

read -p "Install Network? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	#yum install -y firewalld firewall-config
	#yum install -y samba-client samba-common cifs-utils autofs nfs-utils
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
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
# PFtrack
	yum install -y /mnt/kabbalah/library/Software/Linux/PixelFarm/pftrack-2016*.rpm
	yum install -y /mnt/kabbalah/library/Software/Linux/PixelFarm/pfmanager-2018*.rpm
# DJV
	yum install -y /mnt/kabbalah/library/Software/Linux/DJV/DJV*.rpm
# Deadline
	/mnt/kabbalah/library/Software/Linux/Thinkbox/DeadlineClient*.run --mode unattended --licensemode LicenseFree --connectiontype Remote --proxyrootdir 192.168.69.20:2847 --slavestartup true --launcherdaemon false
#DaVinci Resolve
	# this needs to be installed as a user and not as root.
	echo "/mnt/kabbalah/library/Software/Linux/Blackmagic/DaVinci_Resolve_Studio_*.run -iy" > /install_Resolve.sh
# GitAhead
	cd /opt/
	/mnt/kabbalah/library/Software/Linux/GitAhead/GitAhead*.sh -y

cat > /home/davidabbott/.local/share/applications/GitAhead.desktop <<EOF
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
	yum install -y /mnt/kabbalah/library/Software/Linux/ImagineerSystems/MochaPro2020*.rpm

cat > /home/davidabbott/.local/share/applications/mochapro2020.desktop << EOF
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
	/mnt/kabbalah/library/Software/Linux/NeatVideo/NeatVideo*.run --mode console

# Nuke10.5
	NUKE10="/mnt/kabbalah/library/Software/Linux/Foundry/Nuke-10.5*.run"
	chmod +x $NUKE10
	mkdir /opt/Nuke10.5v4 && cd $_
	unzip $NUKE10
	#cp /mnt/kabbalah/library/Software/Linux/Foundry/Nuke10.5/libidn.so.11 /opt/Nuke10.5v4
	#cp /mnt/kabbalah/library/Software/Linux/Foundry/Nuke10.5/libGLU.so.1.3.1 /lib64

cat > /home/davidabbott/.local/share/applications/Nuke10.5v4.desktop <<EOF
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

cat > /home/davidabbott/.local/share/applications/NukeX10.5v4.desktop <<EOF
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

# Nuke12.1
	NUKE12="/mnt/kabbalah/library/Software/Linux/Foundry/Nuke-12.1*.run"
	chmod +x $NUKE12
	cd /opt
	$NUKE12 --accept-foundry-eula

cat > /home/davidabbott/.local/share/applications/Nuke12.1v1.desktop <<EOF
[Desktop Entry]
Name=Nuke12.1v1
Exec=env QT_SCALE_FACTOR=1.5 /opt/Nuke12.1v1/Nuke12.1
Comment=
Terminal=true
MimeType=application/x-nuke;
Icon=/opt/Nuke12.1v1/plugins/icons/NukeApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

cat > /home/davidabbott/.local/share/applications/NukeX12.1v1.desktop <<EOF
[Desktop Entry]
Name=NukeX12.1v1
Exec=env QT_SCALE_FACTOR=1.5 /opt/Nuke12.1v1/Nuke12.1 -b --nukex %f
Comment=
Terminal=true
MimeType=application/x-nuke;
Icon=/opt/Nuke12.1v1/plugins/icons/NukeXApp48.png
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;FLTK;
EOF

# set mimetype
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
	/mnt/kabbalah/library/Software/Linux/Redshift/redshift_v2.6.5*.run --quiet
# Slack
	yum install -y /mnt/kabbalah/library/Software/Linux/Slack/slack*.rpm
# Zoom
	RPM_ZOOM="/mnt/kabbalah/library/Software/Linux/Zoom/zoom_x86_64.rpm"
	wget -q https://zoom.us/client/latest/zoom_x86_64.rpm -O $RPM_ZOOM
	yum install -y $RPM_ZOOM

# update mime
	update-mime-database /usr/share/mime
fi

read -p "Install Licences? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	mkdir -p /usr/local/foundry/RLM/
	RLM="/usr/local/foundry/RLM/"
	echo "HOST 192.168.69.2 any 4101" > $RLM/wifi.lic
	echo "HOST 192.168.3.2 any 4101" > $RLM/wireguard.lic
	echo "HOST 192.168.69.4 any 4101" > $RLM/ethernet.lic
fi

exit 0