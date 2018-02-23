#!/bin/bash

if [ -f ~/scripts/generic-linux-funcs.sh ]; then
	. ~/scripts/generic-linux-funcs.sh
elif [ -f ./generic-linux-funcs.sh ]; then
	. ./generic-linux-funcs.sh
fi


usage()
{
  echo
  echo "Usage: `basename $0` DIR MASK CMD"
  echo
  echo "Example: `basename $0` /tmp/ '*.txt' 'rm -f' # Will call rm -f <file> for every *.txt file written/created in /tmp"
  echo "       `basename $0` -d(ownload) \$remotefile \$localfile  [\$sshargs]"
  echo
  echo "       current working directory."
  echo
  exit 1
}

[ -z "$1" -o -z "$2" -o -z "$3" ] && usage

regex="$2"
cmd_to_run="$3"

declare -A FILES_DONE=()

inotifywait -m "$1" -e create -e moved_to -e modify |
	while read path action file; do
		hm \* "The file '$file' appeared in directory '$path' via '$action'"
		if [[ "$file" =~ $regex ]]; then
			echo $action "$file"
			if [[ -n "${FILES_DONE[$file]}" ]]; then
				hm - "File '$file' already processed."
			else
				# Path is given with trailing '/'
				hm + "$cmd_to_run ${path}${file}"
				#FILES_DONE+=("${file}")
				FILES_DONE[$file]=1 # Set it to any value
			fi
		else
			hm - " ! Didn't match regex $regex"
		fi
		# do something with the file
	done

