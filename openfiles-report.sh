#!/bin/bash

COLUMNS=$(tput cols)

(
	cd /proc
	total_fds=0
	for pid in [0-9]*; do
		fd_dir="/proc/$pid/fd"
		if [ -d "$fd_dir" ]; then
			num_fds=$(ls -1 "$fd_dir" | wc -l)
			total_fds=$((total_fds+num_fds))
    	printf "%.${COLUMNS}s\n" "${num_fds} ${pid} $(cat /proc/${pid}/cmdline)"
		fi
	done 
	/bin/echo -e "${total_fds} All procs combined."
) | sort -n 

exit 0
