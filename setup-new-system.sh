#!/bin/sh

echo "Setting up your new system, just sit back and relax..."

if [ -f ~/.bashrc.bak ]; then
	echo "Bashrc seems already installed"
else
	mv -v ~/.bashrc ~/.bashrc.bak
	ln -s ~/scripts/bashrc ~/.bashrc
	echo "New bashrc installed"
fi

echo "New bash installed"


COMMONPKGS="vim nmap htop git gitk screen lynx links elinks libreoffice httrack okular kdm kate gedit sshpass"
if [ -x /usr/bin/yum ]; then
	PKGS="$COMMONPKGS system-config-lvm ionice"
	CMD=yum
fi
if [ -x /usr/bin/apt-get ]; then
	PKGS="$COMMONPKGS gnome-system-monitor aircrack-ng openvas-cli openvas-scanner openvas-manager ettercap-graphical git-gui wine gdb dkms autofs cifs-utils libdigest-crc-perl libstring-crc32-perl libcpan-checksums-perl sysfsutils uswsusp apmd"
	CMD=apt-get
fi
echo "Installing some useful packages: $PKGS"
sudo $CMD install $PKGS
