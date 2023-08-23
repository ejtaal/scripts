#!/bin/bash

echo updating yt-dlp

if [ -r ~/venvs/yt-dlp/bin/activate ]; then
	echo Found and sourcing virtualenv...
	source ~/venvs/yt-dlp/bin/activate
	EXE=yt-dlp
else
	EXE=/home/taal/.local/bin/yt-dlp
fi
pip3 install yt-dlp

URL="$1"
RANGE="$2"

OPTIONAL_NAME=''

if [ -n "$3" ]; then
	OPTIONAL_NAME="_${3// /_}"
fi


#cd All
#ls -lart | tail
echo -n "Give the time range e.g.: "
#read END

END='*10:15-10:20'
END='*3:55:00-3:56:00'

$EXE \
	-v \
	--no-part --no-mtime \
	--no-post-overwrites --embed-thumbnail --restrict-filenames \
	-o "%(uploader)s_%(upload_date)s_%(title)s_%(section_start)s-%(section_end)s${OPTIONAL_NAME}.%(ext)s" \
	--download-sections "*$RANGE" \
	--ignore-errors "$URL"
	#--ignore-errors 'https://www.twitch.tv/videos/1842862160?filter=archives&sort=time'
