#!/bin/bash

# This should help figure out which packages you installed over time, to help you
# create better setup scripts that will install things for you next time you
# install a new machine.

LAST_BATCH_TS=0
# Set to 120 seconds, i.e. everything installed within a 2 min timeframe is considered part of the same batch
BATCH_SIZE=120

dpkg-query -W --showformat '${db-fsys:Last-Modified} ${Package}\n' \
| sort -n \
| while read timestamp package; do
	if (( ($timestamp - $LAST_BATCH_TS) > $BATCH_SIZE )); then
		echo
		echo -n "New batch at: $(date -d @$timestamp): $package"
		LAST_BATCH_TS=$timestamp
	else
		echo -n " $package"
	fi
done
