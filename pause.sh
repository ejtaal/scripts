#!/bin/sh

PAUSE_FILE=/tmp/systemwide_pause_jobs.flag
WAIT_TIME=${1:-5}

while [ -f "$PAUSE_FILE" ]; do
	echo "$(date) - $(basename $0): Flag at $PAUSE_FILE found, waiting $WAIT_TIME seconds..."
	sleep $WAIT_TIME
done


echo "$(date) - $(basename $0): Flag at $PAUSE_FILE not found, not pausing."
