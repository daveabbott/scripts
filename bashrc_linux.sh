# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# bash
alias mkdir='mkdir -pv' # create parent directories on demand
alias ping='ping -c 5' # stop after sending count 5 packets
alias reboot='sudo /sbin/reboot'
alias shutdown='sudo /sbin/shutdown'

# applications
alias houdini="/opt/hfs17.5/bin/happrentice"
alias nuke="/opt/Nuke10.5v4/Nuke10.5 --nukex"
alias resolve="/opt/resolve/bin/resolve"

# virtualgl
alias vglhoudini="vglrun -d :1 /opt/hfs17.5/bin/happrentice"
alias vglnuke="vglrun -d :1 /opt/Nuke10.5v4/Nuke10.5 --nukex"
alias vglresolve="vglrun -d :1 /opt/resolve/bin/resolve"
alias vgltest="vglrun -d :1 /opt/VirtualGL/bin/glxspheres64"

# cuda
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:\$LD_LIBRARY_PATH
export PATH=/usr/local/cuda/bin:\$PATH

# wireguard
alias wg-up="wg-quick up /etc/wireguard/wg0.conf"
alias wg-down="wg-quick down /etc/wireguard/wg0.conf"
alias wg-edit="sudo nano /etc/wireguard/wg0.conf"

# turbovnc
alias turbo="/opt/TurboVNC/bin/vncserver"
alias turbok="/opt/TurboVNC/bin/vncserver -kill :1"

# anaconda
# leave commented unless actually using; breaks GUI.
# alias anancon="conda activate deepfacelab"

# [ -z "\$PS1" ] && return
# [[ ":\$PATH:" =~ ":/home/user/anaconda3/bin:" ]] || PATH="/home/user/anaconda3/bin:\$PATH"