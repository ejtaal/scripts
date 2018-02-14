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
	clear
	{
	echo "==== $(date) ===="
	echo "== Interface info =="
	# network info
	ip addr | egrep -v "valid_lft"
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
	echo "== Routing info =="
	route -n
	# Check VPN / TOR / inet connectivity
	# encrypted FSes
	echo
	echo "== Disk info =="
	lsblk -n | egrep -v " disk "
	} | spc -c ~/scripts/status.spc
	# remote FSes
	# gits info
	# backup info
	if [ -n "$RUNS_REQUESTED" ]; then
		echo "$RUNS_REQUESTED runs requested"
		RUNS_REQUESTED=$((RUNS_REQUESTED-1))
	fi
	SECS=60
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


