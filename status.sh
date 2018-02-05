#!/bin/bash

update_timeout() {
	SECS="$1"

}

EXIT_REQUESTED=0
while [ "$EXIT_REQUESTED" = 0 ] ; do
	clear
	{
	echo "==== $(date) ===="
	echo "== Interface info =="
	# network info
	ip addr | egrep -v "valid_lft"
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
	SECS=2
	while [ "$SECS" -gt 0 ]; do
		echo -en "\rRefresh in: $SECS s ...  "
		SECS=$((SECS-1))
		sleep 1
	done
done


