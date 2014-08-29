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



if [ -x /usr/bin/yum ]; then
	PKGS="vim htop nmap git gitk system-config-lvm ionice"
	CMD=yum
fi
if [ -x /usr/bin/apt-get ]; then
	PKGS="gnome-system-monitor vim nmap htop aircrack-ng openvas-client openvas-plugins-base openvas-plugins-dfsg openvas-server ettercap-graphical nmap git-gui gitk wine gdb screen"
	CMD=apt-get
fi
echo "Installing some useful packages: $PKGS"
sudo $CMD install $PKGS
