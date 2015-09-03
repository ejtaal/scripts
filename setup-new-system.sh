#!/bin/sh

# wget -O - https://github.com/ejtaal/scripts/raw/master/setup-new-system.sh | sh

echo "Setting up your new system, just sit back and relax..."

cd
if [ ! -d scripts ]; then
	git clone https://github.com/ejtaal/scripts
fi

if [ -f ~/.bashrc.bak ]; then
	echo "Bashrc seems already installed"
else
	mv -v ~/.bashrc ~/.bashrc.bak
	ln -s ~/scripts/bashrc ~/.bashrc
	echo "New bashrc installed"
fi

echo "New bash installed"


COMMONPKGS="vim nmap htop git gitk screen lynx links elinks libreoffice httrack okular kate gedit sshpass lftp mtr iotop krusader vlc xine-ui smplayer mc"
if [ -x /usr/bin/yum ]; then
	PKGS="$COMMONPKGS system-config-lvm ionice"
	CMD=yum
fi
if [ -x /usr/bin/apt-get ]; then
	PKGS="$COMMONPKGS gnome-system-monitor aircrack-ng openvas-server openvas-cli openvas-client openvas-manager ettercap-graphical git-gui wine gdb dkms autofs cifs-utils libdigest-crc-perl libstring-crc32-perl libcpan-checksums-perl sysfsutils uswsusp apmd veil-evasion fbreader libstring-crc-cksum-perl libgeo-ip-perl linux-headers-`uname -r` iptraf-ng openssh-blacklist openssh-blacklist-extra mosh"
	FOUND_PKGS=""
	for i in $PKGS; do
		if apt-cache show $i; then
			FOUND_PKGS="$FOUND_PKGS $i"
		else
			echo package ''$i'' not found.
		fi
	done
	PKGS="$FOUND_PKGS"
	CMD=apt-get
fi
echo "Installing some useful packages: $PKGS"
sudo $CMD install $PKGS

if [ -f /etc/apt/sources.list ]; then
	. /etc/lsb-release
	#echo $DISTRIB_CODENAME
	echo
	echo "===="
	echo
	echo "=> Potentionally interesting deb repositories:
sudo add-apt-repository ppa:jaap.karssenberg/zim
deb http://download.virtualbox.org/virtualbox/debian $DISTRIB_CODENAME contrib
'wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -'
sudo apt-get update
sudo apt-get install virtualbox-5.0 zim"

fi


