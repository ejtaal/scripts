#!/bin/bash

# Some very useful (to me anyway) generic linux funcs.
# These mainly gather information about running processing, detecting
# which apps are running and how many instances of it/them.
# It returns the information in a terse format, mainly for use in my
# super fancy mega ultra bash prompt :), see bashrc for that.

PATH="/sbin:$PATH"

# Define some useful colour names
esc="\e"; boldon="${esc}[1m"; boldoff="${esc}[22m"; reset="${esc}[0m"
blackb="${esc}[40m";   redb="${esc}[41m";    greenb="${esc}[42m"
yellowb="${esc}[43m"   blueb="${esc}[44m";   purpleb="${esc}[45m"
cyanb="${esc}[46m";    whiteb="${esc}[47m"
italicson="${esc}[3m"; italicsoff="${esc}[23m"
ulon="${esc}[4m";      uloff="${esc}[24m"
redf="${esc}[31m";  greenf="${esc}[32m";  yellowf="${esc}[33m";
bluef="${esc}[34m"; purplef="${esc}[35m"; cyanf="${esc}[36m";
blackf="${esc}[30m"
redfb="${esc}[1m${esc}[31m";  greenfb="${esc}[1m${esc}[32m";  yellowfb="${esc}[1m${esc}[33m";
bluefb="${esc}[1m${esc}[34m"; purplefb="${esc}[1m${esc}[35m"; cyanfb="${esc}[1m${esc}[36m";

# Check printf -v
printf -v RanDomVar "%s" testing123 2> /dev/null
if [ "$RanDomVar" != 'testing123' ]; then
	PRINTF_V_DUFF=y
else
	unset RanDomVar
fi

get_basic_dist_info() {
	system_type=$(uname)
	kernel_info="?"
	os_info="?"
	proc_info="?"
	num_processors="?"
	num_cores="?"
	#VM_TYPE=`vm_check`
	vm_check

	# Also some basic kernel info
	if [ $system_type = FreeBSD ]; then
		os_info=$(uname -r)
		kernel_info=$(uname -i)
		proc_info=$(uname -p)

		dmesg_boot="/var/run/dmesg.boot"
		num_processors=$(grep "^CPU:" $dmesg_boot | wc -l)
		proc_ghz=$(grep -m 1 "^CPU:" $dmesg_boot | perl -pi -e 's/.*?([\d\.]+)GHz.*/$1/')
		num_cores="$(grep "^cpu" $dmesg_boot | wc -l)"
		total_mem_GB=$(grep "^real memory" $dmesg_boot | awk '{ print $4 / (1024*1024*1024) }')

	elif [ $system_type = Linux ]; then
		# Personally, need to cater for RHEL, CentOS, ubuntu, FreeBSD
		kernel_info=$(uname -r | sed 's/-.*//')
		proc_info=$(uname -m)
		if [ -f /etc/lsb-release ]; then
			. /etc/lsb-release
		fi
		if [ "$DISTRIB_ID" = "Ubuntu" ]; then
			os_icon=U
			os_color="$purplefb"
			os_release="$DISTRIB_RELEASE"
			os_release_better=$(echo ${DISTRIB_DESCRIPTION} | sed -e 's/[^0-9\.]//g')
			if [ -n "$os_release_better" ]; then
				os_release=$os_release_better
			fi
		elif [ "$DISTRIB_ID" = "LinuxMint" ]; then
			os_icon=Mint
			os_color="$boldon$greenf"
			os_release="$DISTRIB_RELEASE"
		elif [ -f /etc/redhat-release ]; then
			if head -1 /etc/redhat-release | grep -qi 'Red Hat Enterprise Linux'; then
				os_icon="RHEL"
				os_release=$(head -1 /etc/redhat-release | sed -e 's/[^0-9\.]//g')
				os_color="$boldon$redf"
			elif head -1 /etc/redhat-release | grep -qi 'CentOS'; then
				os_icon="CentOS"
				os_release=$(head -1 /etc/redhat-release | sed -e 's/[^0-9\.]//g')
				os_color="$boldon$greenf"
			fi
		elif [ -f /etc/issue ]; then
			# Alas, LSB was of no use
			if head -1 /etc/issue | grep -qi ubuntu; then
				# Maybe could also use /etc/lsb-release in future?
				os_info=$(head -1 /etc/issue | sed -e 's/ \\.*//')
				os_icon="U"
				os_color="$purplefb"
			elif head -1 /etc/issue | grep -qi 'KDE neon'; then
				os_icon="Neon"
				os_color="${blackb}${cyanfb}"
				os_release=$(head -1 /etc/issue | tr -Cd '0-9.')
			elif head -1 /etc/issue | grep -qi 'Mint'; then
				os_icon="Mint"
				os_color="${blackb}${greenfb}"
				os_release=$(head -1 /etc/issue | tr -Cd '0-9.')
			elif head -1 /etc/issue | grep -qi kali; then
				os_icon="Kali"
				os_color="${blackb}${redfb}"
				if grep '[0-9]' /etc/issue; then
					os_release=$(head -1 /etc/issue | sed -e 's/[^0-9.]//g')
				else
					os_release="~$(dpkg -l | grep 'kali-' | awk '{ print $3 }' | sort -n | tail -1)"
				fi
			elif head -1 /etc/issue | grep -qi centos; then
				os_info=$(head -1 /etc/issue | sed -e 's# release##' -e 's/ (.*//')
				os_icon="CentOS"
				os_color="$greenfb"
			elif head -1 /etc/issue | grep -qi ^red; then
				os_info=$(head -1 /etc/issue | sed -e 's/Red Hat Linux/RH/' -e 's/Red Hat Enterprise Linux/RHEL/' -e 's# release##' -e 's# Server##' -e 's/ (.*//')
				os_icon="RHEL"
				os_color="$redfb"
			fi
		elif [ -x /usr/bin/lsb_release ]; then
			os_release=$(/usr/bin/lsb_release -rs)
			os_desc=$(/usr/bin/lsb_release -ds)
		fi
	
		# http://linuxhunt.blogspot.com/2010/03/understanding-proccpuinfo.html
		num_phys="$(grep ^phys /proc/cpuinfo | sort | uniq | wc -l)"
		num_cores="$(grep ^core /proc/cpuinfo | sort | uniq | wc -l)"
		num_visible="$(grep "^processor" /proc/cpuinfo | wc -l)"
		proc_ghz=$(grep -m 1 "^cpu MHz" /proc/cpuinfo | awk '{ print $4 / 1000 }')
	
		total_mem_GB="$(grep MemTotal: /proc/meminfo | awk '{ print $2 / (1024*1024) }')"
		if [ -n "$VM_TYPE" ]; then
			vcpu="$VM_TYPE:"
		fi
	fi

	mem_info="$(printf "%.1fGB" ${total_mem_GB})"
	cpu_info="$(printf "%dx%s%.1fGHz(%dp,%dc)" $num_visible "$vcpu" $proc_ghz $num_phys $num_cores)"

	#echo "${system_type}/$os_info/$kernel_info/$proc_info/${mem_info}/${num_processors}cpu/${num_cores}core"
	#echo "${system_type}/$os_info/$kernel_info/$proc_info/${mem_info}/${cpu_info}"
	# Don't echo any longer, we're passing variables around now
}

system_info() {
	
	if which screen 2> /dev/null | grep -q "^/"; then
		screens=$(screen -ls | egrep "^[0-9]+ Sockets* in" | sed 's/ Socket.*//')
		if [ "$screens" != "" ]; then
			echo -n "scr: $screens "
		fi
	fi
	term_screen_num=$(w -sh | grep -c ':S\.[0-9]')
	term_x_num=$(w -sh | grep -c ' :[0-9]')
	echo -n "terms(scr:${term_screen_num} x:$term_x_num) "

	# Use wc -l as pgrep -c is not available on RH 7.3
	ssh_logins=$(pgrep -f "sshd: $USER@" | wc -l)
	if [ $ssh_logins -gt 0 ]; then echo -n "ssh: $ssh_logins "; fi
	
	sftp_servers=$(pgrep sftp-server | wc -l)
	if [ $sftp_servers -gt 0 ]; then echo -n "sftp: $sftp_servers "; fi
	
	vnc_servers=$(pgrep -f 'vnc :' | wc -l)
	if [ $vnc_servers -gt 0 ]; then echo -n "vnc: $vnc_servers "; fi

	# List virtual machines found running on the machine:
###	VM_ENABLED=n
###	if which virsh      > /dev/null; then
###		if which VirtualBox > /dev/null; then
###			VM_ENABLED=y
###			if virsh -c vbox:///session list 2>&1 | grep -q ^error; then
###				vbox_total_vms='?'
###				vbox_active_vms='?'
###			else
###				vbox_total_vms_message=$(virsh -c vbox:///session list --all)
###				vbox_total_vms=$(echo "$vbox_total_vms_message" | egrep "^ +([0-9]|-)" | wc -l)
###				vbox_active_vms=$(echo "$vbox_total_vms_message" | grep " running" | wc -l)
###			fi
###			echo -n "VM: vbox($vbox_active_vms/$vbox_total_vms) "
###		fi
###		# TODO KVM, xen etc.
###	fi
	# virsh above is too slow, let's try VBoxManage straight up
	#echo -n .
	#if which VBoxManage > /dev/null; then
	if [ -d "$HOME/.VirtualBox" ]; then
		vbox_total_vms=$(grep -c MachineEntry $HOME/.VirtualBox/VirtualBox.xml)
		if [ "${vbox_total_vms}" -gt 0 ]; then
			#vbox_total_vms_message=$(virsh -c vbox:///session list --all)
			#vbox_total_vms=$(VBoxManage list vms | grep -c '^"')
			#vbox_active_vms=$(VBoxManage list runningvms | grep -c '^"')
			vbox_active_vms_gui=$(pgrep -fc 'VirtualBox .* --startvm')
			vbox_active_vms_headless=$(pgrep -fc 'VBoxHeadless -s .')
			echo -n "vbox: "
			[ "${vbox_active_vms_headless}" != "0" ] && echo -n " nogui:${vbox_active_vms_headless}/"
			[ "${vbox_active_vms_gui}" != "0" ] && echo -n "gui:${vbox_active_vms_gui}/"
			echo -n "total:$vbox_total_vms "
		fi
	fi

	QEMU_KVM_VMS=$(pgrep -lf qemu-kvm | sed 's/^.*\-name \(.*\) -uuid.*/\1/')
	if [ -n "$QEMU_KVM_VMS" ]; then
		echo -n "qemu/kvm: $QEMU_KVM_VMS"
	fi

	if [ "$DISPLAY" != "" ]; then
		echo -n "X:${DISPLAY##*:} "
	fi
	
	vims=$(pgrep 'vim' | wc -l)
	if [ $vims -gt 0 ]; then echo -n "vim: $vims "; fi
		
	IPS=$(ip addr | grep 'inet ' | grep -v 127.0.0 | cut -f 1 -d'/' | awk '{ print $2 }' | xargs)
	GATEWAY=$(ip route | grep ^default | awk '{ print $3 "(" $5 ")" }')
	echo -n "ip: ${IPS}->$GATEWAY "

	for i in /sys/class/power_supply/BAT*; do
		if [ ! -f "$i" ]; then continue; fi
		bat=$(basename $i)
		cap=$(cat $i/capacity)
		status=$(cat $i/status | cut -b -3)
		echo -n "$bat($status):${cap}% "
	done


}

#
# vm_check() will do some quick and dirty checks to see if we're running virtual:
# It will return an empty string if it couldn't detect anything, else the name
# of the type of VM host used.
#
vm_check() {
	# Quick n dirty checks to see if we're running virtual
  VM_TYPE=""
  if [ -f /proc/user_beancounters -o -d /proc/vz ]; then
    VM_TYPE="OPENVZ"  # Or Virtuozzo
		VM_COLOR="$blackb$greenfb"
  elif grep -qi "QEMU Virtual CPU" /proc/cpuinfo; then
    VM_TYPE="QEMU"
		VM_COLOR="$blackb$purplef"
	elif [ -r /proc/timer_list ] && grep -qi 'Clock Event Device: xen' /proc/timer_list; then
    VM_TYPE="XEN"
		VM_COLOR="$whiteb$blackf"
	elif [ -r /proc/bus/input/devices ] && grep -q VirtualBox /proc/bus/input/devices; then
    VM_TYPE="VBOX"
		VM_COLOR="$bluefb$blackb"
	elif [ -r /var/log/dmesg ] && grep -q "^hd.: VBOX " /var/log/dmesg; then
    VM_TYPE="VBOX"
		VM_COLOR="$bluefb$blackb"
	elif uname -r | grep -qi Microsoft; then
		# Pigs can finally fly, it's 2019 and we have M$ Linux O_O
    VM_TYPE="WSL"
		# Windows home path seems to leak through the $PATH
		WINDOWS_HOME=$(echo $PATH | sed 's#.*:\(/mnt/c/Users/[^/]*\)/.*#\1#')
		
		if [ ! -L ~/WinHome ]; then
			ln -vs $WINDOWS_HOME ~/WinHome
		fi

		VM_COLOR="$whitefb$blueb"
	elif uname -s | grep -q MINGW64; then
		# Either Git Bash or Msys
    VM_TYPE="MINGW"
		# No need to set this as $HOME etc is available correctly
		#WINDOWS_HOME=$(echo $PATH | sed 's#.*:\(/mnt/c/Users/[^/]*\)/.*#\1#')
		VM_COLOR="$redfb$blackb"
	else
		for i in /sys/devices/virtual/dmi/id/product_name /proc/scsi/scsi; do
			if [ -f $i ] && grep -qi "VMware" $i; then
    		VM_TYPE="VMware"
				VM_COLOR="$blueb$yellowfb"
			fi
		done
	fi
	#echo "$VM_TYPE"
}

hexToIp(){
	k=$2
	if [ "$PRINTF_V_DUFF" = y ]; then
		eval $1=$(printf "%d.%d.%d.%d" 0x${k:6:2} 0x${k:4:2} 0x${k:2:2} 0x${k:0:2})
	else
		printf -v $1 "%d.%d.%d.%d" 0x${k:6:2} 0x${k:4:2} 0x${k:2:2} 0x${k:0:2}
	fi
}


mydebug() {
	echo -n "DEBUG: "
	for i in "$@"; do
		eval echo -n " $i = [\$$i] "
	done
	echo
}

hexToInt() {
	#check PRINTF_V_DUFF?
    printf -v $1 "%d\n" 0x${2:6:2}${2:4:2}${2:2:2}${2:0:2}
}

intToIp() {
	#check PRINTF_V_DUFF?
	local	iIp=$2
	printf -v $1 "%s.%s.%s.%s" $(($iIp>>24)) $(($iIp>>16&255)) $(($iIp>>8&255)) $(($iIp&255))
}

urlencode() {
    # urlencode <string>

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c"
        esac
    done
		# Or:
    # urldecode <string>
		#$ alias urldecode='python -c "import sys, urllib as ul; \
		#    print ul.unquote_plus(sys.argv[1])"'
}

urldecode() {
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
		
		# Or:
		#		$ alias urlencode='python2 -c "import sys, urllib as ul; \
		#		    print ul.quote_plus(sys.argv[1])"'
		# decoded_url=$(python3 -c 'import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))' "$encoded_url")
}

string_morph(){
	s=$1
	echo "<<< string >>>"
	echo "$s"
	echo "<<< /string >>>"
	echo "<<< base64 >>>"
	echo "$1" | base64
	echo "<<< /base64 >>>"
	echo "<<< base64 decode (fed through xxd)>>>"
	echo "$1" | base64 -d | xxd
	echo "<<< /base64 decode >>>"
	echo
	echo "hex no        : "
	printf "%x" $s
	echo
	echo "hex           : "
  local length="${#s}"
  for (( i = 0; i < length; i++ )); do
    local c="${s:i:1}"
    printf '\\x%02X' "'$c"
  done
	echo
	echo "hex decoded   : " 
	echo "$1" | xxd -r -p
	echo
	echo "numchars      : "
  for (( i = 0; i < length; i++ )); do
    local c="${1:i:1}"
    printf '%d ' "'$c"
  done
	echo
	echo "alphabet chars: "
  for (( i = 0; i < length; i++ )); do
    local c="${1:i:1}"
    echo -n "$(($(printf '%d' "'$c")-96)) "
  done
	echo
	echo "urlencode     : "
  for (( i = 0; i < length; i++ )); do
      local c="${1:i:1}"
      case $c in
          [a-zA-Z0-9.~_-]) printf "$c" ;;
          *) printf '%%%02X' "'$c"
      esac
  done
	echo
	echo "urldecode     : "
	python3 -c 'import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))' "$1"
	echo
	echo "urldecode (forced): "
  for (( i = 0; i < length; i++ )); do
    local c="${1:i:1}"
    printf '%%%02X' "'$c"
  done
	echo
}

get_external_ip() {
	dig +short myip.opendns.com @resolver1.opendns.com
}

hm() {
	# Display a hacker message. Lame, I know :-/
	color="$greenfb"
	icon="$1"
	case "$icon" in
		'!') color="$redfb";;
		'-') color="$yellowfb";;
		'+') color="$greenfb";;
		'*') color="$cyanfb";;
	esac
	shift
	echo -en "${color}[${icon}] "
	echo -n "$@"
	echo -e "${reset}"
	
}

modify_file() {
  # This modifies a conf file and replaces specific wmfs lines
  # with input to this function
  filename="$1"
  shift
  if [ ! -f "${filename}" ]; then
    hm - "Couldn't find ${filename}"
		touch "${filename}"
	fi
	if [ ! -w "${filename}" ]; then
    hm ! "Can't write to ${filename}"
		filename="/tmp/$(basename "$filename")"
		hm + "Writing contents instead to: $filename"
		touch "${filename}"
	else
  	cp -pf "${filename}" "${filename}.old"
  fi
  sed -n '/start-my-conf/,/end-my-conf/!p' "${filename}" \
    > "${filename}.new"
  echo "### start-my-conf - You better don't be messing with these lines, fool!!" >> "${filename}.new"
  for string in "$@"; do
    echo -e "$string" >> "${filename}.new"
  done
  echo "### end-my-conf - I told you not to mess with the lines above, fool!!" >> "${filename}.new"
  chmod --reference="${filename}" "${filename}.new"
  chown --reference="${filename}" "${filename}.new"
  mv -f "${filename}.new" "${filename}"
	hm + "Updated $filename"
}

# A multi-threading implementation. How to use:
# loop over commands you need executing and pass them to 'add_threads()'
# E.g.:
# $ threads_addcmd( "sleep 5")
# $ threads_addcmd( "sleep 15")
# $ threads_addcmd( "sleep 25")
# Then execute the threads by doing
# $ threads_run()
# You'll be placed in a screen session with all threads executing the given commands
# spread over your available cpu cores

# Keep 2 threads for the system and we'll use the rest ;-p
THREADS_TOTAL=$(($(grep -c ^processor /proc/cpuinfo)-2))
THREADS_CMDS=()
THREADS_CUR=0

threads_addcmd() {
	THREADS_CMDS[THREADS_CUR]="${THREADS_CMDS[THREADS_CUR]}$*;"
	echo "==>> Command '$*' added to thread# $THREADS_CUR"
	THREADS_CUR=$((THREADS_CUR+1))
	if [ "$THREADS_CUR" = "$THREADS_TOTAL" ]; then
		THREADS_CUR=0
	fi
}

threads_run() {
	echo '
# Some usefull status lines scattered over the screen ;)
hardstatus alwayslastline
caption always "%{= C} %S | screen[%n] | %c | %h%="
hardstatus string "%{= .W}%-Lw%{= C}%50>[%n* %t]%{-}%+Lw%<"
windowlist string " screen[%n %t] %h"
' > "/tmp/threads_screenrc_test_$$"
	err_log="/tmp/threads_screenrc_test_$$.err"
	> $err_log
	if [ ${#THREADS_CMDS[*]} -eq 0 ]; then
		echo "No commands have been specified. Use threads_addcmd() to add commands."
		return 1
	fi
	echo $((${#THREADS_CMDS[*]}-1))
	for i in `seq 0 $((${#THREADS_CMDS[*]}-1))`; do
		threadfile="/tmp/sh_thread_$$_no_${i}.sh"
		echo '#!/bin/bash' > "$threadfile"
		echo "exec 2> >(tee -a $err_log)" >> "$threadfile"
		chmod +x "$threadfile"
		echo "${THREADS_CMDS[i]}" >> "$threadfile"
		echo "echo Waiting 5 secs before exit..." >> "$threadfile"
		echo "sleep 5" >> "$threadfile"
		echo "screen -t thread_${i} bash -c '$threadfile'" \
			>> "/tmp/threads_screenrc_test_$$"
	done
	echo screen -S "sh_threads_$$" -c "/tmp/threads_screenrc_test_$$"
	time nice -n 20 screen -S "sh_threads_$$" -c "/tmp/threads_screenrc_test_$$"
	date
	echo "==> All threads (read 'screen') finished."
	echo "Errors that occurred:"
	ls -la $err_log
	cat $err_log
	THREADS_CMDS=()
}

myapt() {

	case "$1" in
			install)
				command="$1"
				shift
				PKGS="$*"
				;;
			upgrade)
				command="$1"
				shift
				PKGS="$(apt list --upgradable | grep upgradable | cut -f 1 -d '/')"
				;;
			*)
				echo command not recognized.
				return
				;;
		esac

		for pkg in $PKGS; do
			echo "==>> Attempting install of '$pkg' ..."
			TIMEOUT=120
			if fuser -v /var/lib/dpkg/lock; then
				echo -n "Lock detected, waiting "
				touch /tmp/myapt-request
				while [ "$TIMEOUT" -gt 0 ] && fuser -s /var/lib/dpkg/lock; do
					TIMEOUT=$((TIMEOUT-1))
					sleep 1
					echo -n '.'
				done
			fi
			if fuser -v /var/lib/dpkg/lock; then
				echo "Lock persists past timeout, giving up on package"
				rm -f /tmp/myapt-request
				return
			fi
			apt install -y "$pkg"
			# Give another apt a chance to take the lock
			if [ -f /tmp/myapt-request ]; then
				sleep 3
			fi
		done
}

swap-increase-temp() {
	if [ "$(id -u)" != 0 ]; then
		hm - "Not recommended to run this as non-root user"
		return
	fi
	hm \* "Attempting to increase swap by 1 GB"
	grep -i swap /proc/meminfo
	SWAPFILE=$(mktemp)
	dd if=/dev/zero of="$SWAPFILE" bs=1M count=1k
	chmod 0600 "$SWAPFILE"
	mkswap "$SWAPFILE"
	if swapon "$SWAPFILE"; then
		hm + "Success"
		grep -i swap /proc/meminfo
	else
		hm - "Failed"
		grep -i swap /proc/meminfo
	fi
}

rainbowify() {
	str="$1"
	rainbow[1]="$boldoff$redf"
	rainbow[2]="$boldon$redf"
	rainbow[3]="$boldoff$yellowf"
	rainbow[4]="$boldon$yellowf"
	rainbow[5]="$boldoff$greenf"
	rainbow[6]="$boldon$greenf"
	rainbow[7]="$boldoff$cyanf"
	rainbow[8]="$boldon$cyanf"
	rainbow[9]="$boldon$bluef"
	rainbow[10]="$boldoff$bluef"
	rainbow[11]="$boldon$purplef"
	rainbow[12]="$boldoff$purplef"
	total=${#rainbow[*]}
	#echo "[$str]"
	length=$(echo "$str" | wc -c)
	for i in {1..12}; do
		start=$(( (i-1)*length/total+1))
		end=$(( i*length/total ))
		#echo "i = $i, start = $start, end = $end"
		substr=$(echo "$str" | cut -b "$start-$end")
		#echo -n "$substr "
		echo -en "${rainbow[i]}${substr}"
	done
	echo -e $reset
}

bright_rainbowify256() {
  str="$1"
##### dark purple blue teal green yellow orange red
rainbow256=( 53 89 125 161 197 
	198 199 200 201 165 129 93 57 
	63 69 33 27 21 20 26 32 39 45 51 50 44 43 37 30 29 28 34 40 46 82 
	118 154 190 226 
	220 214 208 202 
	166 130 94 52 88 124 160 196
	)
	#for k in ${rainbow256[*]}; do
	#	/usr/bin/printf "%b%s%b" "\e[38;5;${k}m" "${k}" "\e[0m"
	#done
	#echo
	#for k in ${rainbow256[*]}; do
	#	/usr/bin/printf "%b%s%b" "\e[38;5;${k}m" "#" "\e[0m"
	#done
	#echo
  
	total=${#rainbow256[*]}
  
	#echo "[$str]"
  length=$(echo "$str" | wc -c)
	print_str=
  for i in `seq 1 $total`; do
    start=$(( (i-1)*length/total+1))
    end=$(( i*length/total ))
    #echo "i = $i, start = $start, end = $end"
		#echo if  $start -gt $end 
		if [ $start -gt $end ]; then
			continue
		fi
		if [ $i = $total ]; then
			#echo MARK
			end=
		fi
    substr=$(echo "$str" | cut -b "$start-$end")
		#echo "SUB = [$substr]"
    #echo -n "$substr "
    #echo -en "${bright_rainbow[i]}${substr}"
		j=$((i-1))
		#print_str="${print_str}\e[38;5;${rainbow256[j]}m${substr}"
		/usr/bin/printf "%b%s" "\e[38;5;${rainbow256[j]}m" "${substr}" 
  done
	#echo -en "${print_str}"
  echo -e $reset
}

tm() {
	TMUX_SESSION="$1"
	if ! tmux att -t $TMUX_SESSION; then
		hm \! "Couldn't find tmux session '$TMUX_SESSION'"
		hm \* "Starting it ..."
		sleep 1
		tmux new -s $TMUX_SESSION
	fi
}

file_older_than_mins() {
	file="$1"
	age="$2"

	if [ ! -r "$file" ]; then
		return 0
	else
		if [ "$(find "$file" -not -mmin "+$age" | wc -l)" = 0 ]; then
			return 0
		else
			return 1
		fi
	fi
	return 0
}

download_if_not_older(){
	file="$1"
	age="$2"
	url="$3"
	if file_older_than_mins "$file" "$age"; then
		echo "-> $file seems old, downloading current version..."
		wget -O "$file" "$url"
	else
		echo "-> $file seems up to date (modified in the last $age mins)."
	fi
	ls -l "$file"
}


venv() {
	VENV_BASE=~/venvs/
	VENV_NAME="$1"
	if [ ! -d "$VENV_BASE/$VENV_NAME" ]; then
		virtualenv "$VENV_BASE/$VENV_NAME"
	fi
	source "$VENV_BASE/$VENV_NAME/bin/activate"
}

