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
	VM_TYPE=`vm_check`

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
			elif head -1 /etc/issue | grep -qi kali; then
				os_icon="Kali"
				os_color="${blackb}${redfb}"
				os_release=$(head -1 /etc/issue | sed -e 's/[^0-9.]//g')
			elif head -1 /etc/issue | grep -qi centos; then
				os_info=$(head -1 /etc/issue | sed -e 's# release##' -e 's/ (.*//')
				os_icon="COS"
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
  if grep -qi "QEMU Virtual CPU" /proc/cpuinfo; then
    VM_TYPE="QEMU"
	elif grep -qi 'Clock Event Device: xen' /proc/timer_list; then
    VM_TYPE="XEN"
	elif test -f /proc/bus/input/devices && grep -q VirtualBox /proc/bus/input/devices \
		|| grep -q "^hd.: VBOX " /var/log/dmesg; then
    VM_TYPE="VBOX"
	else
		for i in /sys/devices/virtual/dmi/id/product_name /proc/scsi/scsi; do
			if [ -f $i ] && grep -qi "VMware" $i; then
    		VM_TYPE="VMware"
			fi
		done
	fi
	echo "$VM_TYPE"
}

hexToIp(){
	k=$2
	if [ "$PRINTF_V_DUFF" = y ]; then
		eval $1=$(printf "%d.%d.%d.%d" 0x${k:6:2} 0x${k:4:2} 0x${k:2:2} 0x${k:0:2})
	else
		printf -v $1 "%d.%d.%d.%d" 0x${k:6:2} 0x${k:4:2} 0x${k:2:2} 0x${k:0:2}
	fi
}

get_default_if() {
	while read -a rtLine ;do
		# In case there's no gateway configured, just grab any configured device
		# Alternatively, maybe look at /proc/net/arp?
		device=${rtLine[0]}
  	if [ ${rtLine[1]} == "00000000" ] && [ ${rtLine[7]} == "00000000" ] ;then
      hexToIp default_gateway ${rtLine[2]}
			#echo $netInt
			#echo "addrLine = [$addrLine]"
			last_2_digits=${default_gateway#[0-9]*.[0-9]*.}
			last_digit=${default_gateway#[0-9]*.[0-9]*.[0-9]*.}
			#device=${rtLine[0]}
			break
		fi
	done < /proc/net/route
	#echo default_gateway = $default_gateway device = $device
	#if_ip=$(ip addr show dev $device | awk -F'[ /]*' '/inet /{print $3;exit}')
	# Read them all in an array, if more than 1
	if [ "$device" = "Iface" ]; then
		if_ip="x.x.x.x"
		last_digit="x"
	else
		if_ips=($(ip addr show dev $device | awk -F'[ /]*' '/inet /{print $3}'))
		if_ip=${if_ips[0]}
		#if_ip=$(ip addr show dev $device | awk -F'[ /]*' '/inet /{print $3}')
		first_3_if_ip=${if_ip%.[0-9]*}
		
		if [ ${#if_ips[@]} -gt 1 ]; then
			for (( i=1; i<${#if_ips[@]}; i++ )); do
				alt_ip=${if_ips[$i]}
				first_3_alt_ip=${if_ips[$i]%.[0-9]*}
				last_digit_alt_ip=${alt_ip#[0-9]*.[0-9]*.[0-9]*.}
				#mydebug alt_ip first_3_alt_ip last_digit_alt_ip first_3_if_ip
				if [ "$first_3_if_ip" = "$first_3_alt_ip" ]; then
					if_ip="$if_ip +${last_digit_alt_ip}"
				else
					if_ip="$if_ip $alt_ip"
				fi
			done
		fi
	
	fi
	first_3_gateway=${default_gateway%.[0-9]*}
	#arrow=">"
	arrow="→"
	if [ "$first_3_if_ip" = "$first_3_gateway" ]; then
		if_gateway_info="${if_ip} $arrow${last_digit}"
	else
		# Could be none found:
		if [ -z "${last_2_digits}" ]; then
			last_2_digits='_'
		fi
		if_gateway_info="${if_ip} $arrow${last_2_digits}"
	fi

	# Other ips active:
	other_ips=$(ip addr show  | egrep -v "($device|127.0.0.1)" | awk -F'[ /]*' '/inet /{print $3}' | xargs echo -n)
	if [ -n "$other_ips" ]; then
		if_gateway_info="$other_ips / $if_gateway_info"
	fi
	if_gateway_info="| $if_gateway_info"
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
	echo "==>> string [$s]:"
	echo -n "base64        : "
	echo "$1" | base64
	echo -n "base64 decoded: "
	echo "$1" | base64 -d
	echo
	echo -n "hex           : "
  local length="${#s}"
  for (( i = 0; i < length; i++ )); do
    local c="${s:i:1}"
    printf '\\x%02X' "'$c"
  done
	echo
	echo -n "numchars      : "
  for (( i = 0; i < length; i++ )); do
    local c="${1:i:1}"
    printf '%d ' "'$c"
  done
	echo
	echo -n "urlencode     : "
  for (( i = 0; i < length; i++ )); do
      local c="${1:i:1}"
      case $c in
          [a-zA-Z0-9.~_-]) printf "$c" ;;
          *) printf '%%%02X' "'$c"
      esac
  done
	echo
	echo -n "urldecode     : "
	python3 -c 'import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))' "$1"
	echo
	echo -n ",, forced     : "
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
	echo -e "${color}[${icon}] $@${reset}"
	
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
