#!/bin/bash

run_curl() {
	file="$1"
	output="$2"
	curl \
		-X POST http://localhost:8000/v1/audio/transcriptions   \
		-H "Content-Type: multipart/form-data"   \
		-o "$output" \
		-F "file=@$file"   \
		-F model=whisper-1   \
		-F timestamps=true   \
		-F diarize=true
}


if [ -z "$1" ]; then
	echo "Usage: $(basename $0) MEDIA_FILE"
	echo
	echo "This will transcribe MEDIA_FILE using parakeet-diarized (https://github.com/jfgonsalves/parakeet-diarized)."
fi

MEDIA_FILE="$1"
JSON_FILE="$(echo "$1" | grep -oP '^(.*\.)')json"
TXT_FILE="$(echo "$1" | grep -oP '^(.*\.)')txt"

if [ -s "$JSON_FILE" ]; then
	echo "$JSON_FILE already exists."
else
	run_curl "$MEDIA_FILE" "$JSON_FILE"
fi

cat "$JSON_FILE" \
| jq -r '.text' \
| perl -pe '
	# Give each speaker a new line
	s/(Speaker \d+:)/\n\1/g; 
	s/([\.\?]) (\d+: ?)/\1\n\2/g;
	# Change to MS-DOS file format
	s#([^\r]*?)\n#\1\r\n#g;
	' \
| cat > "$TXT_FILE"




