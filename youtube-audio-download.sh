#!/bin/bash

cd $(dirname $0)

echo "In directory $PWD"

echo -n "Enter youtube url: "
read url
#url='https://www.youtube.com/watch?v=5OEI6hJyGq8'

echo "processing url '$url' ..."

#youtube-dl --restrict-filenames --write-description --write-info-json \
PREFIX=$(date | md5sum | cut -b 1-6)
youtube-dl --restrict-filenames \
	-o "./${PREFIX}_%(title)s-%(id)s.%(ext)s" -x --audio-format mp3 --add-metadata \
	"$url"

INFILE=$(ls -1 ${PREFIX}_*.mp3)
MP3="${INFILE#*_}"

#avconv -i "$INFILE" -vn -b:a 64k "${MP3}"
mv -vi "$INFILE" "${MP3}"

# optional:
# remove silence - http://digitalcardboard.com/blog/2009/08/25/the-sox-of-silence/
#sox -V3 "${MP3}_temp.mp3" "$MP3" silence -l 1 0.1 1% -1 2.0 1%

mp3gain -r "$MP3" && echo "Deleting temp file..." && rm -vf "$INFILE"

echo "Here's your new mp3:"
ls -l "$MP3"

THIS_DEVICE="$(df -h . | tail -1 | awk '{ print $1 }')"
echo "If sorting is required, 'eject' device but keep it plugged in,"
echo "then run 'sudo fatsort $THIS_DEVICE'"

echo "Bye bye :)"
for i in {9..1}; do echo -n "$i "; sleep 1; done
