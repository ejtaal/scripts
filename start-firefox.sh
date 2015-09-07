#!/bin/sh

cd ~/firefoxes

if [ -n "$1" ]; then
	BROWSER_PATH="$(pwd)/${1}/"
	BROWSER_DIR="${1}"
	if [ ! -d "$BROWSER_PATH" ]; then
		echo "Error: directory '$BROWSER_PATH' doesn't exist."
		exit 1
	fi
else
	counter=0
	echo "The following Firefox sessions are available (with # of tabs):"
	for dir in *; do
		if [ ! -d "$dir" -o "$dir" = "session-backups" ]; then 
			continue
		fi
		counter=$((counter+1))
		#echo cd $dir/.mozilla/firefox/*.default
		win_count=$(cd $dir/.mozilla/firefox/*.default && ~/scripts/count-firefox-tabs.py)
		#win_count="?"
		printf " %2d : $dir ($win_count)\n" $counter
		eval dir_$counter="$dir"
	done

	echo -n "Choose wisely: "
	read number
	
	eval BROWSER_PATH="$(pwd)/\$dir_${number}/"
	eval BROWSER_DIR="\$dir_${number}"
	echo "You've chosen: $BROWSER_DIR"
fi

if [ ! -d "$BROWSER_DIR" ]; then
	echo "! The directory '$BROWSER_DIR' doesn't exist! Fix this first."
	exit 1
fi

perl -pi.bak -e "s/^Name=.*$/Name=${BROWSER_DIR}/" "${BROWSER_PATH}/.mozilla/firefox/profiles.ini"

echo "Launching firefox: HOME=${BROWSER_PATH} firefox -no-remote -P ${BROWSER_DIR}"

if [ ! -L ${BROWSER_PATH}/Desktop ]; then
	mv ${BROWSER_PATH}/Desktop ${BROWSER_PATH}/Desktop.bak
	ln -s ~/Desktop ${BROWSER_PATH}/Desktop
fi

if [ ! -L ${BROWSER_PATH}/Downloads ]; then
	mv ${BROWSER_PATH}/Downloads ${BROWSER_PATH}/Downloads.bak
	ln -s ~/Downloads ${BROWSER_PATH}/Downloads
fi

HOME=${BROWSER_PATH} firefox -no-remote -P ${BROWSER_DIR}
