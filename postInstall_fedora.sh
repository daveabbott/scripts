#!/bin/sh

echo -e "set-hostname: double-rabbi"
hostnamectl set-hostname double-rabbi

read -p "Setup yum? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	dnf makecache
	dnf install -y dnf-utils
	dnf install -y deltarpm
	dnf groupinstall -y "Development Tools"
	dnf install -y kernel-devel
	dnf install -y dkms
	dnf update
fi

read -p "Install Repos " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	rpm --import https://www.turbovnc.org/key/VGL-GPG-KEY
	yum-config-manager --add-repo=https://turbovnc.org/pmwiki/uploads/Downloads/TurboVNC.repo

	rpm --import https://www.virtualgl.org/key/VGL-GPG-KEY
	yum-config-manager --add-repo=https://virtualgl.org/pmwiki/uploads/Downloads/VirtualGL.repo

	yum-config-manager --add-repo=https://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo

	curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo

cat > /etc/yum.repos.d/cuda.repo << EOF
[cuda]
name=cuda
baseurl=http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64
enabled=1
gpgcheck=1
gpgkey=http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/7fa2af80.pub
EOF

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

	# auto mount
	mkdir /mnt/kabbalah
	echo "/mnt/kabbalah /etc/auto.kabbalah --timeout=60" > /etc/auto.master

	echo "active  -fstype=nfs  192.168.69.20:/volume1/Active" > /etc/auto.kabbalah
	echo "library  -fstype=nfs  192.168.69.20:/volume1/Library" >> /etc/auto.kabbalah
	echo "media  -fstype=nfs  192.168.69.20:/volume1/Media" >> /etc/auto.kabbalah
	echo "temp  -fstype=nfs  192.168.69.20:/volume1/Temp" >> /etc/auto.kabbalah

	systemctl enable autofs
	systemctl restart autofs
fi

read -p "Install Others? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	dnf install -y nano
	dnf install -y gnome-system-monitor
	dnf install -y eog						# eye of gnome image viewer
	dnf install -y gnome-tweak-tool
	dnf install -y libgnome					# this enables Dropbox to be installed
	dnf install -y timeshift
	dnf install -y alacarte					# allow easy changing of app shortcuts
	dnf install -y piper					# mouse configurator
	dnf install -y VirtualGL turbovnc
	dnf install -y steam
	dnf install -y wireguard-dkms wireguard-tools
	# dnf install -y kmod-hfs kmod-hfsplus hfsplus-tools
	dnf install -y VirtualBox-6.0.x86_64
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
	sudo snap install gitkraken
	sudo snap install opera
	sudo snap install slack --classic
	sudo snap install spotify
	sudo snap install sublime-text --classic
	sudo snap install vlc
fi

read -p "Install VFX? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	rpm -i '/mnt/kabbalah/library/Software/Linux/PixelFarm/pftrack-2016.24.29-1.x86_64.rpm'
	rpm -i '/mnt/kabbalah/library/Software/Linux/PixelFarm/pfmanager-2018.13.28-1.x86_64.rpm'
	rpm -i '/mnt/kabbalah/library/Software/Linux/DJV/DJV*.rpm'

	/mnt/kabbalah/library/Software/Linux/Thinkbox/Deadline-*-linux-installers/DeadlineClient*.run --mode unattended --licensemode LicenseFree --connectiontype Remote --proxyrootdir 192.168.69.20:2847 --slavestartup true --launcherdaemon false
	
	echo "/mnt/kabbalah/library/Software/Linux/Blackmagic/DaVinci_Resolve_Studio_*.run -y" > /home/davidabbott/Desktop/INSTALL.txt
	echo "sudo /mnt/kabbalah/library/Software/Linux/Foundry/Nuke/Nuke10.5v4-linux-x86-release-64-installer" >> /home/davidabbott/Desktop/INSTALL.txt
fi

read -p "Install Nvidia Drivers? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	systemctl isolate multi-user.target
	bash /mnt/kabbalah/library/Software/Linux/Nvidia/NVIDIA-Linux-x86_64-*.run
fi

read -p "Add SSH Keys? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	mkdir /home/davidabbott/.ssh
	echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKavYG91YOvgYPUOcNze9aK28+DPRnCvdqTXgrBc2kqS daves-macbook-pro" > /home/davidabbott/.ssh/authorized_keys
fi

exit 0