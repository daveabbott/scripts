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
	dnf remove -y \
	libreoffice* \
	gnome-weather \
	gnome-weather \
	gnome-boxes \
	rhythmbox \
	cheese \
	gnome-contacts \
	firefox
# install 
	dnf makecache

	dnf install -y \
	dnf-utils \
	kernel-devel \
	kernel-headers \
	dkms

	dnf groupinstall -y "Development Tools"

	dnf update -y

	dnf install -y \
	fedora-workstation-repositories \
	gnome-tweak-tool \
	timeshift \
	
	# cinnamon
	dnf install -y \
	cinnamon \
	nemo-fileroller

	# THESE ARE NEED FOR PRODUCTION
	dnf install -y libnsl						# needed for Houdini
	dnf install -y libGLU						# needed for Nuke
	dnf install -y libusb						# needed for PFTrack


	#dnf install -y chrome-gnome-shell # ads gnome support to firefox
		# gnome extensions
		# https://extensions.gnome.org/extension/517/caffeine/
		# https://extensions.gnome.org/extension/1160/dash-to-panel/
		# https://extensions.gnome.org/extension/6/applications-menu/	
	
# flatpak
	# add repo
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	# install flatpaks
	flatpak install -y flathub \
	com.bitwarden.desktop \
	org.mozilla.firefox \
	org.mozilla.Thunderbird \
	com.slack.Slack \
	us.zoom.Zoom
	fr.handbrake.ghb \
	com.makemkv.MakeMKV \
	org.blender.Blender \
	fr.natron.Natron \
	com.rawtherapee.RawTherapee \
	io.github.RodZill4.Material-Maker \
	com.quixel.Bridge \
	org.videolan.VLC
	com.spotify.Client
	com.sublimetext.three \
	flathub com.sublimemerge.App
	
	# folder permisions
	# blender
	flatpak override --filesystem=/mnt/DATUMS/SCRATCH/blender org.blender.Blender
	# quixel
	flatpak override --filesystem=/mnt/kabbalah/library/Stock\ Assets/Megascans\ Library com.quixel.Bridge
	

# network settings	
	dnf install -y firewalld firewall-config
	dnf install -y samba-client samba-common cifs-utils autofs nfs-utils
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
	# autofs
	systemctl enable autofs
	systemctl restart autofs
	
# nvidia
	chmod +x /mnt/kabbalah/library/Software/_drivers/Nvidia/NVIDIA*.run
	
	dnf install -y kernel-devel kernel-headers gcc make dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig
	
	echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
	
	sed -i '/GRUB_CMDLINE_LINUX/c\GRUB_CMDLINE_LINUX="rhgb quiet rd.driver.blacklist=nouveau"' /etc/sysconfig/grub

#GRUB_TIMEOUT=5
#GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
#GRUB_DEFAULT=saved
#GRUB_DISABLE_SUBMENU=true
#GRUB_TERMINAL_OUTPUT="console"
#GRUB_CMDLINE_LINUX="rhgb quiet"
#GRUB_DISABLE_RECOVERY="true"
#GRUB_ENABLE_BLSCFG=true

	dnf remove xorg-x11-drv-nouveau

	dracut /boot/initramfs-$(uname -r).img $(uname -r) --force


# https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&target_distro=Fedora&target_version=32&target_type=rpmnetwork

	sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora32/x86_64/cuda-fedora32.repo
	sudo dnf clean all
	sudo dnf -y module install nvidia-driver:latest-dkms
	sudo dnf -y install cuda

	echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf

	grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

	dnf remove xorg-x11-drv-nouveau

	dracut /boot/initramfs-$(uname -r).img $(uname -r) --force
	
	systemctl set-default multi-user.target

# turbovnc
	rpm --import https://www.turbovnc.org/key/VGL-GPG-KEY
	dnf config-manager --add-repo=https://turbovnc.org/pmwiki/uploads/Downloads/TurboVNC.repo
	dnf install -y turbovnc
# virtualgl
	rpm --import https://www.virtualgl.org/key/VGL-GPG-KEY
	dnf config-manager --add-repo=https://virtualgl.org/pmwiki/uploads/Downloads/VirtualGL.repo
	dnf install -y VirtualGL 
# wireguard
	dnf copr enable jdoss/wireguard -y
	dnf install -y wireguard-dkms wireguard-tools
# virtualbox
	dnf config-manager --add-repo=https://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo
	dnf install -y VirtualBox-6.0.x86_64
# makemkv
	dnf config-manager --add-repo=https://negativo17.org/repos/fedora-multimedia.repo
	sed -i '/repo_gpgcheck=0/a exclude=*cuda* *nvidia* *ffmpeg* *gstreamer* *HandBrake* *live555* x264-libs x265-libs *vlc*' /etc/yum.repos.d/fedora-multimedia.repo # this prevents clashes with RPMFusion
	dnf install -y makemkv libdvdcss
	echo "T-UWwbYn781f1gjZcH5NOsJkGgWHnUkQsr2IduoSJ8sssNXOqclsWhowNWTclkBjHIMH" > /makemkv-betakey.txt
# cuda
	dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/fedora29/x86_64/cuda-fedora29.repo
	dnf --disablerepo="rpmfusion-nonfree*" install cuda
	echo "blacklist nouveau" > /usr/lib/modprobe.d/blacklist-nouveau.conf
	echo "options nouveau modeset=0" >> /usr/lib/modprobe.d/blacklist-nouveau.conf
	dracut --force
	grub2-mkconfig -o /boot/grub2/grub.cfg
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
	systemctl restart firewalld
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
	# deleting all but the nvidia .icd files may help this run
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
	dnf install -y /mnt/kabbalah/library/Software/Linux/ImagineerSystems/MochaPro2020*.rpm

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
	/mnt/kabbalah/library/Software/Linux/NeatVideo/NeatVideo*.run --mode console

# Nuke10.5
	NUKE10="/mnt/kabbalah/library/Software/Linux/Foundry/Nuke-10.5*.run"
	cp $NUKE10 /opt
	chmod +x /opt/Nuke-10.5*.run
	mkdir /opt/Nuke10.5v4 && cd $_
	unzip /opt/Nuke-10.5*.run
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
Exec=/opt/Nuke12.0v5/Nuke12.0 -q--nukex
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
	dnf install -y /mnt/kabbalah/library/Software/Linux/Slack/slack*.rpm
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

exit 0
