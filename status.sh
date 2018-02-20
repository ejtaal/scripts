#!/bin/bash

# Input processing:
# rd4 = route del (4)
# vpn-1 1.2.3.4  = route only traffic for 1.2.3.4 through vpn-1
# i2d = interface (2) do dhcp
# i

update_timeout() {
	SECS="$1"
}

RUNS_REQUESTED="$1"
EXIT_REQUESTED=0
while [ "$EXIT_REQUESTED" = 0 ] ; do
	#{
	echo "==== $(date) ===="
	echo "== Interface info =="
	# network info
	#ip addr | egrep -v "valid_lft" 
	ip addr | egrep -v "valid_lft" \
		| sed -e 's/inet6 \(.*\) scope link/\1/' \
			-e 's/> mtu.*/>/' \
			-e 's/ link\/.* \(.*\) brd .*/\1/' \
			-e 's/inet \(.*\) brd .*/\1/' \
			-e 's/ scope host .*//' \
			-e 's/ \+/ /g' \
			-e 's/<.*,\(UP\),.*>/\1/g' \
			| awk 'NR%4{printf "%s",$0;next;}1'
	echo
	echo
	echo "== Internet/WWW info =="
	PORTALINFO=$(curl -s detectportal.firefox.com/success.txt)
	echo -n "WWW: "
	if [ "$PORTALINFO" = "success" ]; then
		echo -n OK
	else
		echo -n 'Portal?'
	fi
	echo -n ' External IP: '
	curl ipecho.net/plain;echo
	#dig +time=2 +short myip.opendns.com @208.67.222.222 #@resolver1.opendns.com
	echo
	echo
	echo "== GIT info =="
	for repodir in ~/scripts ~/repos/*; do
		if [ -d "$repodir/.git" ]; then
			pushd "$repodir" > /dev/null
			echo -n "$repodir "
			git status -sb | xargs | cut -b -40
			popd > /dev/null
		fi
	done
	echo
	echo "== Listen info =="
	netstat -ntulp | grep -i LIST | egrep -v " 127.0.| ::1:"
	echo
	echo "== Routing info =="
	route -n
	# Check VPN / TOR / inet connectivity
	# encrypted FSes
	
	echo
	echo "== Disk info =="
	lsblk -n | egrep -v " disk "
	
	echo
	echo "== Git info =="
	for gitdir in ~/scripts ~/repos/*; do
		if [ -d "$gitdir/.git" ]; then
			pushd "$gitdir" > /dev/null
			echo -n "$gitdir : "
			#fetch remotes if done more than 30 mins ago
			filename=.git/FETCH_HEAD
			#$(( (`date +%s` - `stat -L --format %Y $filename`) > (30*60) ))
			if [ -f $filename ] && [ $(date +%s) -lt $((`stat -L --format %Y $filename`+(30*60) )) ]; then
				git fetch
			fi
			#BEHIND_CANFWD=$(git status | egrep 'Your branch is behind.*can be fast-forwarded' | sed -e 's/^.* by /behind by /' -e 's/, and/,/')
			# Or git rev-list --count master..origin/master / git rev-list --count origin/master..master
			#  / git status -sb / git branch -vv
			#echo -n "$BEHIND_CANFWD "
			git status -sb | xargs | cut -b -60
			popd > /dev/null
		fi
	done
	echo
	echo
	echo "== DNS info =="
	DNS_SRVS=
	if grep resolvconf /etc/resolv.conf > /dev/null; then
		DNS_SRVS="$(nmcli dev show | grep -i DNS | awk '{ print $2 }')"
	fi
	DNS_SRVS="$DNS_SRVS $(grep ^nameserver /etc/resolv.conf | awk '{ print $2 }')"
	for i in $DNS_SRVS; do
		echo -n "$i:"
		if ping -w 2 -W 1 -c 2 $i 2>&1 > /dev/null; then
			echo -n OK
		else
			echo -n '!ping'
		fi
		if host -W 2 c.cc $i 2>&1 > /dev/null; then
			echo -n '/OK'
		else
			echo -n '/!DNS'
		fi
		echo -n ' '
	done
	echo
	echo
	#} 2>&1 > /tmp/test.txt
	#clear
	#spc -c ~/scripts/status.spc /tmp/test.txt
	# remote FSes
	# gits info
	# backup info
###	SECS=10
###	echo -en "\rRefresh in: $SECS s ...  "
###	read -t $SECS input
###	case $input in
###		t)
###			echo test
###			read dummy
###			;;
###		t2)
###			echo test2
###			read dummy
###			;;
###	esac

	#while [ "$SECS" -gt 0 ]; do
	#	echo -en "\rRefresh in: $SECS s ...  "
	#	SECS=$((SECS-1))
	#	sleep 1
	if [ -n "$RUNS_REQUESTED" ]; then
		echo "$RUNS_REQUESTED runs requested"
		RUNS_REQUESTED=$((RUNS_REQUESTED-1))
	fi
	SECS=30
	while [ "$SECS" -gt 0 ]; do
		echo -en "\rRefresh in: $SECS s ...  "
		SECS=$((SECS-1))
		sleep 1
	done
	if [ -n "$RUNS_REQUESTED" ]; then
		if [ "$RUNS_REQUESTED" -lt 1 ]; then
			echo "This was the last run"
			exit 0
		fi
	fi
done


