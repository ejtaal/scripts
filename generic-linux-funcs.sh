#!/bin/sh

# Some very useful (to me anyway) generic linux funcs.
# These mainly gather information about running processing, detecting
# which apps are running and how many instances of it/them.
# It returns the information in a terse format, mainly for use in my
# super fancy mega ultra bash prompt :), see bashrc for that.

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
  VM_TYPE=""
  if grep -qi "QEMU Virtual CPU" /proc/cpuinfo; then
    VM_TYPE="QEMU"
	elif test -f /proc/bus/input/devices && grep -q VirtualBox /proc/bus/input/devices \
		|| grep -q "^hd.: VBOX " /var/log/dmesg; then
    VM_TYPE="VBOX"
	elif test -f /proc/scsi/scsi && grep -qi "VMware" /proc/scsi/scsi; then
    VM_TYPE="VMware"
	fi
	echo "$VM_TYPE"
}

hexToIp(){
	k=$2
	printf -v $1 "%d.%d.%d.%d" 0x${k:6:2} 0x${k:4:2} 0x${k:2:2} 0x${k:0:2}
}

get_default_if() {
	while read -a rtLine ;do
  	if [ ${rtLine[1]} == "00000000" ] && [ ${rtLine[7]} == "00000000" ] ;then
      hexToIp default_gateway ${rtLine[2]}
			#echo $netInt
			#echo "addrLine = [$addrLine]"
			last_2_digits=${default_gateway#[0-9]*.[0-9]*.}
			last_digit=${default_gateway#[0-9]*.[0-9]*.[0-9]*.}
			device=${rtLine[0]}
			break
		fi
	done < /proc/net/route
	if_ip=$(ip addr show dev $device | awk -F'[ /]*' '/inet /{print $3}')
	first_3_if_ip=${if_ip%.[0-9]*}
	first_3_gateway=${default_gateway%.[0-9]*}
	#arrow=">"
	arrow="→"
	if [ "$first_3_if_ip" = "$first_3_gateway" ]; then
		if_gateway_info="${if_ip} $arrow${last_digit}"
	else
		if_gateway_info="${if_ip} $arrow${last_2_digits}"
	fi
}

hexToInt() {
    printf -v $1 "%d\n" 0x${2:6:2}${2:4:2}${2:2:2}${2:0:2}
}

intToIp() {
	local	iIp=$2
	printf -v $1 "%s.%s.%s.%s" $(($iIp>>24)) $(($iIp>>16&255)) $(($iIp>>8&255)) $(($iIp&255))
}
