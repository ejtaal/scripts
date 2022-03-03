#!/bin/sh

PAUSE_FILE=/tmp/systemwide_pause_jobs.flag
WAIT_TIME=${1:-5}

if [ -f "$PAUSE_FILE" ]; then
	echo "$(date) - $(basename $0): Flag at $PAUSE_FILE found, waiting $WAIT_TIME seconds..."
	while [ -f "$PAUSE_FILE" ]; do
		/bin/echo -ne "$(date) - $(basename $0): Flag at $PAUSE_FILE found, waiting $WAIT_TIME seconds...\r"
		sleep $WAIT_TIME
	done
fi


echo "$(date) - $(basename $0): Flag at $PAUSE_FILE not found, not pausing."
