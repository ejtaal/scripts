#!/bin/sh

for i in /sys/class/power_supply/BAT*; do
	bat=$(basename $i)
	full=$(cat $i/charge_full)
	now=$(cat $i/charge_now)
	model=$(cat $i/model_name)
	tech=$(cat $i/technology)
	current=$(cat $i/current_now)
	status=$(cat $i/status)
	#perc=$((current*100/full))
	cap=$(cat $i/capacity)
	echo "$bat ($model/$tech): $status ${cap}% full"
done
