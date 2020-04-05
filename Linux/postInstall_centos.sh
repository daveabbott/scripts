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
	yum install -y deltarpm
	yum groupinstall -y "Development Tools"
	yum install -y kernel-devel
	yum install -y dkms
	yum update
fi

read -p "Install Repos " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	rpm --import https://www.turbovnc.org/key/VGL-GPG-KEY
	yum-config-manager --add-repo=https://turbovnc.org/pmwiki/uploads/Downloads/TurboVNC.repo

	rpm --import https://www.virtualgl.org/key/VGL-GPG-KEY
	yum-config-manager --add-repo=https://virtualgl.org/pmwiki/uploads/Downloads/VirtualGL.repo

	rpm --import https://negativo17.org/repos/RPM-GPG-KEY-slaanesh
	yum-config-manager --add-repo=https://negativo17.org/repos/epel-steam.repo
	
	rpm --import http://elrepo.org/RPM-GPG-KEY-elrepo.org
	rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

	yum-config-manager --add-repo=https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo

	yum-config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-rhel7.repo

	yum-config-manager --add-repo=https://negativo17.org/repos/epel-spotify.repo

	curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo

cat > /etc/yum.repos.d/epel-multimedia.repo << EOF
[epel-multimedia]
name=negativo17 - Multimedia
baseurl=https://negativo17.org/repos/multimedia/epel-\$releasever/\$basearch/
enabled=1
skip_if_unavailable=1
gpgkey=https://negativo17.org/repos/RPM-GPG-KEY-slaanesh
gpgcheck=1
enabled_metadata=1
metadata_expire=6h
type=rpm-md
repo_gpgcheck=0
exclude=*cuda* *nvidia*

[epel-multimedia-source]
name=negativo17 - Multimedia - Source
baseurl=https://negativo17.org/repos/multimedia/epel-\$releasever/SRPMS
enabled=0
skip_if_unavailable=1
gpgkey=https://negativo17.org/repos/RPM-GPG-KEY-slaanesh
gpgcheck=1
enabled_metadata=1
metadata_expire=6h
type=rpm-md
repo_gpgcheck=0
EOF
fi

read -p "Install GUI? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	yum groupinstall -y "X Window System"
	yum install -y gnome-classic-session gnome-terminal gnome-tweak-tool gnome-disk-utility nautilus-open-terminal control-center
	systemctl disable gdm
	unlink /etc/systemd/system/default.target
	ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target
	systemctl enable gdm
fi

read -p "Install Fonts? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	yum groupinstall -y "Fonts"
	yum install -y liberation*fonts wine*fonts
fi

read -p "Install Network? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	yum install -y firewalld firewall-config
	yum install -y samba-client samba-common cifs-utils autofs nfs-utils

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
	echo "archive  -fstype=nfs  192.168.69.20:/volume1/Archive" >> /etc/auto.kabbalah
	echo "library  -fstype=nfs  192.168.69.20:/volume1/Library" >> /etc/auto.kabbalah
	echo "temp  -fstype=nfs  192.168.69.20:/volume1/Temp" >> /etc/auto.kabbalah
	
	mkdir /mnt/airbag
	read -p 'Username: ' uservar
	read -sp 'Password: ' passvar
	echo airbag credential are the same as macbook credentials
	echo "username=$uservar" > /etc/pwd_airbag.txt
	echo "password=$passvar" >> /etc/pwd_airbag.txt
	unset uservar passvar
	echo "/mnt/airbag /etc/auto.airbag --timeout=60" > /etc/auto.master
	echo "LDRIVE  -fstype=cifs,rw,noperm,credentials=/etc/pwd_airbag.txt  ://L-ABProjects/LDRIVE" > /etc/auto.airbag
	echo "SDRIVE  -fstype=cifs,rw,noperm,credentials=/etc/pwd_airbag.txt  ://L-ABProjects/SDRIVE" >> /etc/auto.airbag

	systemctl enable autofs
	systemctl restart autofs
fi

read -p "Install Others? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	yum install -y file-roller
	yum install -y wget
	yum install -y ffmpeg
	yum install -y libQt5Svg				# I forget what requires this. Maybe Mocha?
	yum install -y handbrake
	yum install -y spotify-client
	yum install -y wine
	yum install -y nano
	yum install -y gnome-system-monitor
	yum install -y chrome-gnome-shell			# allows firefox to install gnome extensions
	yum install -y eog					# eye of gnome image viewer
	yum install -y gnome-tweak-tool
	yum install -y libgnome					# this enables Dropbox to be installed
	yum install -y timeshift
	yum install -y alacarte					# allow easy changing of app shortcuts
	yum install -y piper					# mouse configurator
	yum install -y VirtualGL turbovnc
	yum install -y steam
	yum install -y wireguard-dkms wireguard-tools
	yum install -y kmod-hfs kmod-hfsplus hfsplus-tools
	yum install -y VirtualBox-6.0.x86_64
	yum install -y qt-x11.x86_64 			# required for Redshift Licencing Tool
	yum install -y libpng12 			# required for Redshift Licencing Tool
	yum install -y redhat-lsb-core 			# required for Redshift
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

read -p "Setup Theme? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	mkdir -p /usr/share/themes/ && cd $_
	git clone https://github.com/EliverLara/Nordic.git

	mkdir -p /github/ && cd $_
	git clone https://github.com/vinceliuice/Tela-icon-theme.git

# shrink ridiculouly oversized title bar in gnome
cat > ~/.config/gtk-3.0/gtk.css << EOF
headerbar {
    min-height: 0px;
    padding-left: 2px;
    padding-right: 2px;
}

headerbar entry,
headerbar spinbutton,
headerbar button,
headerbar separator {
    margin-top: 0px;
    margin-bottom: 0px;
}

/* shrink ssd titlebars */
.default-decoration {
    min-height: 0;
    padding: 3px;
}

.default-decoration .titlebutton {
    min-height: 0px;
    min-width: 0px;
}

window.ssd headerbar.titlebar {
    padding-left: 6px;
    padding-right: 6px;
    padding-top: 3px;
    padding-bottom: 3px;
    min-height: 0;
}

window.ssd headerbar.titlebar button.titlebutton {
    padding-top: 3px;
    padding-bottom:3px;
    min-height: 0;
}
EOF
fi

read -p "Install Snaps? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	sudo yum -y install snapd
	sudo ln -s /var/lib/snapd/snap /snap
	systemctl enable snapd
	systemctl start snapd
	echo "pausing for 5 seconds while snapd starts"
	sleep 5
	sudo snap install snap-store
	sudo snap install bitwarden
	sudo snap install blender --classic
	sudo snap install gimp
	#sudo snap install gitkraken
	#sudo snap install opera
	sudo snap install slack --classic
	#sudo snap install spotify
	sudo snap install sublime-text --classic
	sudo snap install vlc
fi

read -p "Install Lutris? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	cd /github
	git clone https://github.com/jatin-cbs/Lutris-RHEL-CentOS7.git
	sh /github/Lutris-RHEL-CentOS7/lutris*.sh
fi

read -p "Install VFX? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	rpm -i '/mnt/kabbalah/library/Software/Linux/PixelFarm/pftrack-2016.24.29-1.x86_64.rpm'
	rpm -i '/mnt/kabbalah/library/Software/Linux/PixelFarm/pfmanager-2018.13.28-1.x86_64.rpm'
	rpm -i '/mnt/kabbalah/library/Software/Linux/DJV/DJV*.rpm'

	/mnt/kabbalah/library/Software/Linux/Thinkbox/Deadline-*-linux-installers/DeadlineClient*.run --mode unattended --licensemode LicenseFree --connectiontype Remote --proxyrootdir 192.168.69.20:2847 --slavestartup true --launcherdaemon false
	
	echo "Nuke and Resolve need to be installed from GUI. Check /scripts after reboot."
	echo "/mnt/kabbalah/library/Software/Linux/Blackmagic/DaVinci_Resolve_Studio_*.run -y" > /scripts/install_Resolve.sh
	echo "sudo /mnt/kabbalah/library/Software/Linux/Redshift/redshift*.run" > /scripts/install_Redshift.sh

# Nuke10.5
	NUKE10="/mnt/kabbalah/library/Software/Linux/Foundry/Nuke-10.5*.run"
	cp $NUKE10 /opt
	chmod +x /opt/Nuke-10.5*.run
	mkdir /opt/Nuke10.5v4 && cd $_
	unzip /opt/Nuke10.5*.run

# create menu icons
cat > /usr/share/applications/Nuke10.5v4.desktop <<EOF
[Desktop Entry]
Name=Nuke10.5v4
Comment=
Exec="/opt/Nuke10.5v4/Nuke10.5" %f
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
Exec="/opt/Nuke10.5v4/Nuke10.5" -b --nukex %f
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

cat > /usr/share/applications/Nuke12.1v1.desktop <<EOF
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

cat > /usr/share/applications/NukeX12.1v1.desktop <<EOF
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

	update-mime-database /usr/share/mime

fi

read -p "Install Nvidia? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	sudo yum -y install nvidia-driver-latest-dkms cuda
	systemctl isolate multi-user.target
	bash /mnt/kabbalah/library/Software/Linux/Nvidia/NVIDIA-Linux-x86_64-*.run
fi

read -p "Add SSH Keys? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	mkdir /home/davidabbott/.ssh
	echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKavYG91YOvgYPUOcNze9aK28+DPRnCvdqTXgrBc2kqS daves-macbook-pro" > /home/davidabbott/.ssh/authorized_keys
fi

echo "${fin}
################################################
${section} Complete ${less}"

# read -p "Are you ready to reboot? " -n 1 -r
# echo    # (optional) move to a new line
# if [[ $REPLY =~ ^[Yy]$ ]]
# then
#     reboot
# fi

exit 0