#!/bin/bash

# sudo apt-get install git && \
# 	wget -O /tmp/p.sh https://github.com/ejtaal/scripts/raw/master/setup-new-system.sh && \
#		bash /tmp/p.sh
# Or to receive in a fresh VM:
# client: # nc -lvp 4444 > setup.sh && bash ./setup.sh pentest|desktop|...
# server: cat ~/scripts/setup-new-system.sh | nc -q 1 -v $client_IP 4444

echo "Setting up your new system, just sit back and relax..."

cd
if [ ! -d scripts ]; then
	git clone https://github.com/ejtaal/scripts
fi

if [ -f ~/scripts/generic-linux-funcs.sh ]; then
	. ~/scripts/generic-linux-funcs.sh
elif [ -f ./generic-linux-funcs.sh ]; then
	. ./generic-linux-funcs.sh
fi

pushd scripts
./setup-dotfiles.sh
popd

source ~/.bashrc

PRIORITY_PKGS="-y openssh-server git screen tmux htop vim"

# Duff packages: openvas-cli openvas-client openvas-manager openvas-server 

# For WSL and/or lean server installs we could suffice with just cmd line apps:
CMDLINE_PKGS="
automake
bmon
build-essential
clinfo
cryptcat
dc
elinks
expect
fdupes
firefox
g++
gcc-mingw-w64-x86-64
git
gnupg
grc
htop
ionice
iotop
ipcalc
john
lftp
libc6-dev
links
linux-headers-`uname -r` ltrace
lynx
links links2
mtr
man-db
mc
mosh
multitail
netcat
ncdu
nmap
openvpn
p7zip-full
perl-doc
perldoc
pv
pwgen
python3-numpy
python-numpy
r-base-core
screen
sshpass
ssldump
sslscan
strace
supercat
tidy
timelimit
unzip
win-iconv-mingw-w64-dev
"

COMMON_PKGS="
$CMDLINE_PKGS
apmd
autofs
cherrytree
cifs-utils
cpulimit
ddd
dkms
edb-debugger
fatsort
filezilla
gadmin-openvpn-client
gdb
gedit
git-gui
gitk
gparted
httrack
iftop
ike-qtgui
inotify-tools
iptraf-ng
kbtin
kde-spectacle
keepass2
knockd
libav-tools
libcpan-checksums-perl
libdigest-crc-perl
libgeo-ip-perl
libimage-exiftool-perl
libreoffice
libsox-fmt-mp3
libstring-crc32-perl
libstring-crc-cksum-perl
libtool
munin
munin-node
nethogs
ntp-doc
okular
onboard
openssh-blacklist
openssh-blacklist-extra
openssh-server
partimage
python3-notify2
python-notify2
python-pip
python-setuptools
smartmontools
smplayer
sox
sshfs
sysfsutils
system-config-lvm
uswsusp
vinagre
virtualenvwrapper
vlc
wpagui
wicd
wine
"

DESKTOP_PKGS="
$COMMON_PKGS
calibre
csvkit
curl
encfs
fbreader
flashplugin-nonfree
gimp
gnome-system-monitor
grc
hunspell-en-gb
k4dirstat
kate
krusader
mp3info
myspell-en-gb
odt2txt
open-vm-tools-desktop
parcellite
qbittorrent
system-config-lvm
ubuntu-mate-desktop
vinagre
x11vnc
xine-ui
"

PENTEST_PKGS="
$COMMON_PKGS
aircrack-ng
ettercap-graphical
veil-evasion 
wireshark 
hostapd
mate-desktop
mate-desktop-environment
mate-desktop-environment-extras
lightdm
"

FOUND_PKGS=

if [ -x /usr/bin/yum ]; then
	yum makecache
	CHECK_CMD="yum -q -C list"
	CMD=yum
elif [ -x /usr/bin/apt-get ]; then
	CHECK_CMD="apt-cache show"
	#CMD="apt-get -mV --ignore-missing"
	CMD="apt "
	export DEBIAN_FRONTEND=noninteractive
	apt update || exit 1
	#myapt upgrade
	apt upgrade || exit 1
fi

install_pkgs() {
	hm "*" "Finding packages to install..."
	for i in $1; do
		if $CHECK_CMD $i 2>&1 | egrep -qv "No packages found"; then
			hm "+" "Available: $i"
			FOUND_PKGS="$FOUND_PKGS $i"
		else
			hm "-" "Not available: $i"
		fi
	done
	hm "*" "Now installing following useful packages:" $FOUND_PKGS
	sudo $CMD install $FOUND_PKGS || exit 1
}
	
install_pkgs "$PRIORITY_PKGS"
#hm "*" "Finding priority packages to install..."
#ALL_PRIOS_PKG_PRESENT=1
#for i in $PRIORITY_PKGS; do
#	if $CHECK_CMD $i 2>&1 | egrep -qv "No packages found" ; then
#		hm "+" "Found: $i"
#		FOUND_PKGS="$FOUND_PKGS $i"
#	else
#		hm "-" "Not found: $i"
#		ALL_PRIOS_PKG_PRESENT=0
#	fi
#done

#if [ $ALL_PRIOS_PKG_PRESENT = 1 ]; then
#	hm "+" "Priority packages present and accounted for." $PRIORITY_PKGS
#else
#	hm "*" "Installing priority packages first:" $PRIORITY_PKGS
#	sudo $CMD install $PRIORITY_PKGS
#fi
#sudo $CMD install $PRIORITY_PKGS

gitclone() {
	repo="$1"
	commit="$2"
	bn=$(basename $repo)
	mkdir -p "$HOME/github" && pushd $HOME/github
	hm "+" "Cloning $repo ..."
	if [ -d "$bn" ]; then
		cd "$bn" && git pull
	else
		git clone "$repo"
	fi
	popd	
}

PTF_MODULES="
modules/vulnerability-analysis/openvas
modules/vulnerability-analysis/nmap
modules/vulnerability-analysis/droopescan
modules/vulnerability-analysis/whatweb
modules/vulnerability-analysis/nikto
modules/vulnerability-analysis/wpscan
modules/vulnerability-analysis/ike-scan
modules/powershell/powersploit
modules/powershell/nishang
modules/powershell/bloodhound
modules/powershell/empire
modules/reporting/nessus_parser
modules/wireless/mana-toolkit
modules/wireless/aircrackng
modules/intelligence-gathering/discover
modules/intelligence-gathering/httpscreenshot
modules/intelligence-gathering/theHarvester
modules/intelligence-gathering/eyewitness
modules/intelligence-gathering/wafw00f
modules/post-exploitation/crackmapexec
modules/post-exploitation/unicorn
modules/post-exploitation/armitage
modules/password-recovery/cewl
modules/password-recovery/patator
modules/password-recovery/hashcat-utils
modules/password-recovery/crunch
modules/password-recovery/johntheripper
modules/reversing/radare2
modules/exploitation/impacket
modules/exploitation/sqlmap
modules/av-bypass/veil-framework
"
# Put veil at the end as it has annoying windows installers to click through

ptf_install() {
	pushd ~/github/ptf
	> /tmp/ptf.rc
	for module in $1; do
		echo "
use $module
run
exit" >> /tmp/ptf.rc
	done
	echo exit >> /tmp/ptf.rc
	time ./ptf < /tmp/ptf.rc
	popd
}

fix_kali_pg_db() {
	echo -n 'Generating MSF PG_DB user password... '
	PG_PASS="MSF$(pwgen -1 | head -1)"
	echo $PG_PASS
	#psql -c "CREATE USER admin WITH PASSWORD 'test101';"
	/etc/init.d/postgresql start
	# ALTER USER as well in case this scripts runs again and user already exists
echo "CREATE USER msfdev WITH PASSWORD '$PG_PASS';
ALTER USER msfdev WITH PASSWORD '$PG_PASS';
update pg_database set datallowconn = TRUE where datname = 'template0';
\c template0
update pg_database set datistemplate = FALSE where datname = 'template1';
drop database template1;
create database template1 with template = template0 encoding = 'UTF8';
update pg_database set datistemplate = TRUE where datname = 'template1';
\c template1
update pg_database set datallowconn = FALSE where datname = 'template0';
\l" > /tmp/pg.sql
	su - postgres -c "psql < /tmp/pg.sql;
#createuser msfdev -dPRS              # Come up with another great password
createdb --owner msfdev msf_dev_db   # Create the development database
createdb --owner msfdev msf_test_db  # Create the test database"

	mkdir -p $HOME/.msf4
	# Development Database
	echo "development: &pgsql
  adapter: postgresql
  database: msf_dev_db
  username: msfdev
  password: $PG_PASS
  host: localhost
  port: 5432
  pool: 5
  timeout: 5
# Production database -- same as dev
production: &production
  <<: *pgsql" > $HOME/.msf4/database.yml
	hm "*" 'Checking MSF DB connectivity...'
	msfconsole -qx "db_status; exit"
}

choose_setup() {
	if [ -z "$1" ]; then
		hm "*" 'Choose from the following setups to install a base system:'
		grep ' *) #' $0
		#echo "pentest / desktop"
		echo -n '=> '
		read setup_type < /dev/tty
	else
		setup_type="$1"
	fi
		

	case $setup_type in
		pentest) # Will install a nice base pentesting platform, assuming to be running on Kali
			fix_kali_pg_db
			systemctl stop packagekit.service
			systemctl disable packagekit.service
			sleep 2
			install_pkgs "$PENTEST_PKGS"
			# We're going to be root on kali so use 'myapt'
			#myapt install "$PENTEST_PKGS"
			gitclone 'https://github.com/trustedsec/ptf' '' # Add commits for reporting sake etc
			ptf_install "$PTF_MODULES"
			hm "+" "Et voila :)"
			ls -l `find /pentest/ -maxdepth 3 -type f -executable`
			# Licensed stuff:
			# Nessus: needs license put in for every new install
			# Burp: ___
			# Cobalt Strike: needs ~/.cobaltstrike.license
			
			;;
		desktop) # Will install a generic Mate based desktop environment
			# Do different stuff
			install_pkgs "$DESKTOP_PKGS"
			#myapt install "$DESKTOP_PKGS"
			;;
		wsl|server|lean) # Will install a generic Mate based desktop environment
			# Do different stuff
			install_pkgs "$CMDLINE_PKGS"
			;;
		*) hm "-" "entry not recognised"
	esac
}

choose_setup "$1"
