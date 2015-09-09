#!/bin/sh

# wget -O - https://github.com/ejtaal/scripts/raw/master/setup-new-system.sh | sh

echo "Setting up your new system, just sit back and relax..."

cd
if [ ! -d scripts ]; then
	git clone https://github.com/ejtaal/scripts
fi

if [ -L ~/.bashrc ]; then
	echo "Bashrc seems already installed:"
	ls -l ~/.bashrc
else
	mv -v ~/.bashrc ~/.bashrc.bak
	ln -s ~/scripts/bashrc ~/.bashrc
	echo "New bashrc installed"
fi

PKGS="vim nmap htop git gitk screen lynx links elinks libreoffice 
httrack okular kate gedit sshpass lftp mtr iotop krusader vlc xine-ui 
smplayer mc system-config-lvm ionice gnome-system-monitor 
aircrack-ng openvas-server openvas-cli openvas-client openvas-manager 
ettercap-graphical git-gui wine gdb dkms autofs cifs-utils 
libdigest-crc-perl libstring-crc32-perl libcpan-checksums-perl 
sysfsutils uswsusp apmd veil-evasion fbreader 
libstring-crc-cksum-perl libgeo-ip-perl pv
linux-headers-`uname -r` iptraf-ng openssh-blacklist openssh-blacklist-extra 
mosh
"

FOUND_PKGS=

if [ -x /usr/bin/yum ]; then
	#yum makecache
	CHECK_CMD="yum -q -C list"
	CMD=yum
fi
if [ -x /usr/bin/apt-get ]; then
	CHECK_CMD="apt-cache show"
	CMD=apt-get
fi

for i in $PKGS; do
	if $CHECK_CMD $i >/dev/null 2>&1; then
		echo "v $i"
		FOUND_PKGS="$FOUND_PKGS $i"
	else
		echo "- $i"
	fi
done

echo "Found following useful packages:" $FOUND_PKGS
sudo $CMD install $FOUND_PKGS

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


