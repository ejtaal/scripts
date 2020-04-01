#!/bin/sh

CLIP_EXES="
/mnt/c/Windows/System32/clip.exe
"

for ce in $CLIP_EXES; do
	if [ -x "$ce" ]; then
		$ce
		exit 0
	fi
done
echo "Couldn't find a windows clip.exe :("
exit 1
