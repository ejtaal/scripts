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
	
	echo
	echo "== Git info =="
	for gitdir in /mnt/*-webdav/*meta ~/scripts ~/repos/*; do
		if [ -d "$gitdir" ]; then
			pushd "$gitdir" > /dev/null
			echo -n "$gitdir : "
			#fetch remotes if done more than 30 mins ago
			filename=.git/FETCH_HEAD
			#$(( (`date +%s` - `stat -L --format %Y $filename`) > (30*60) ))
			if [ $(date +%s) -lt $((`stat -L --format %Y $filename`+(30*60) )) ]; then
				git fetch
			fi
			#BEHIND_CANFWD=$(git status | egrep 'Your branch is behind.*can be fast-forwarded' | sed -e 's/^.* by /behind by /' -e 's/, and/,/')
			# Or git rev-list --count master..origin/master / git rev-list --count origin/master..master
			#  / git status -sb / git branch -vv
			#echo -n "$BEHIND_CANFWD "
			git status -sb | xargs | cut -b -80
			popd > /dev/null
		fi
	done
	echo
	} | spc -c ~/scripts/status.spc
	# remote FSes
	# gits info
	# backup info
	SECS=10
	echo -en "\rRefresh in: $SECS s ...  "
	read -t $SECS input
	case $input in
		t)
			echo test
			read dummy
			;;
		t2)
			echo test2
			read dummy
			;;
	esac

	#while [ "$SECS" -gt 0 ]; do
	#	echo -en "\rRefresh in: $SECS s ...  "
	#	SECS=$((SECS-1))
	#	sleep 1
	done
done


