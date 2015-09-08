#!/bin/bash


INFILE="$1"
MP3="$2"

#avconv -i "$INFILE" -vn -c:a libmp3lame -b:a 64k "${MP3}_temp.mp3"
avconv -i "$INFILE" -vn -b:a 64k "${MP3}_temp.mp3"


# remove silence - http://digitalcardboard.com/blog/2009/08/25/the-sox-of-silence/
sox -V3 "${MP3}_temp.mp3" "$MP3" silence -l 1 0.1 1% -1 2.0 1%

mp3gain -r "$MP3"
