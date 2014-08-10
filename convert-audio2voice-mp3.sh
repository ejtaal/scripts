#!/bin/sh

TMPFILE="/tmp/a2v.$$.wav"

for file in "$@"; do
	mplayer -vo null -vc null "$file" -ao "pcm:fast:file=$TMPFILE" &&
		lame -v -V 7 -a "$TMPFILE" "${file}.mp3"
done


rm -f "$TMPFILE"
