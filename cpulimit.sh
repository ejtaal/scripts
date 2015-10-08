#!/bin/sh

for pid in $(pgrep -f WMFS) $(pgrep -f Win7); do
	cpulimit -l 25 -p "$pid" &
done
