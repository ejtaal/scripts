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


COMMONPKGS="vim nmap htop git gitk screen lynx links elinks libreoffice httrack okular kdm kate gedit sshpass lftp mtr"
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

if [ -f /etc/apt/sources.list ]; then
	. /etc/lsb-release
	#echo $DISTRIB_CODENAME
	echo "Potentionally interesting deb repositories:
sudo add-apt-repository ppa:jaap.karssenberg/zim
deb http://download.virtualbox.org/virtualbox/debian $DISTRIB_CODENAME contrib
'wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -'
sudo apt-get update
sudo apt-get install virtualbox-5.0 zim"

fi
