#!/bin/bash

RUNNOW=n
if [ "$1" = "now" ]; then
	RUNNOW=y
	shift
fi

TIME="$1"
shift

if [ -z "$TIME" ]; then
	echo "Execute a command here in the terminal at a certain time. Keep this in one of your tmux/screen sessions in lieue of using cron."
	echo
	echo "Usage: $(basename $0) [ \"now\" ] TIME CMD ARG1 ..."
	echo
	echo "Example: $(basename $0) now 1300 mp3-player.sh ~/lunch-alarm.mp3"
	echo "         This would play the mp3 file both now as well as 13:00"
	exit 1
fi

RAN=n

if [ "$RUNNOW" = y ]; then
	"$@"
	echo "$(basename $0) - $(date): Waiting until time $TIME to run the command again: $*"
else
	echo "$(basename $0) - $(date): Waiting until time $TIME to run the command: $*"
fi


while [ "$RAN" = n ]; do
	if [ "$(date +%H%M)" = "$TIME" ]; then
		date
		"$@"
		RAN=y
		break
	fi
	sleep 20
done
