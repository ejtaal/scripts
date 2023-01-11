#!/bin/bash

usage() {
	echo "Usage: $0 [ <project_name> ] <cmd_to_run> [<argument1>] ..."
	echo
	echo "Project_name shall be assume to be empty if \$1 can be resolved to an exetable. In that case project_name will be set to said executable's name."
	exit 1
}

if [ -z "$1" ]; then
	usage
fi

if which $1 2>&1 > /dev/null ; then
	echo "Found executable for '$1', using as project name"
	WHAT="$(basename $1)"
else
	WHAT="$1"
	shift
fi
CMD="$*"
LOG="./${WHAT}-$(date +%Y%m%d-%H%M).scriptlog"


echo ">>> Starting $0 ..." >> "$LOG"
echo ">>> $WHAT" >> "$LOG"
echo ">>> $CMD" >> "$LOG"
echo ">>> $(date)" >> "$LOG"
time script -f -a -c "$CMD" "$LOG"
echo ">>> $(date)" >> "$LOG"
echo "Log is here: $LOG"
