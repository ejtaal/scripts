#!/bin/bash

usage() {
	echo "Usage: $0 <project_name> <cmd_to_run> [<argument1>] ..."
	exit 1
}

if [ -z "$2" ]; then
	usage
fi

WHAT="$1"
shift
CMD="$*"
LOG="./${WHAT}-$(date +%Y%m%d-%H%M).scriptlog"


echo ">>> Starting $0 ..." >> "$LOG"
echo ">>> $WHAT" >> "$LOG"
echo ">>> $CMD" >> "$LOG"
echo ">>> $(date)" >> "$LOG"
time script -f -a -c "$CMD" "$LOG"
echo ">>> $(date)" >> "$LOG"
echo "Log is here: $LOG"
