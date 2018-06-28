#!/bin/bash

if [ -f ~/scripts/generic-linux-funcs.sh ]; then
	. ~/scripts/generic-linux-funcs.sh
elif [ -f ./generic-linux-funcs.sh ]; then
	. ./generic-linux-funcs.sh
fi


usage()
{
  echo
  echo "Usage: `basename $0` BASENAME CMD"
  echo
  echo "       A script to save a command's output to a file for reference, including ansi colour codes etc."
  echo
  echo "Example: `basename $0` greplog grep bash /etc/passwd"
  echo "                       Will store a run of the grep command into greplog-<date-timestamp>.script"
  echo "                       and will convert the .script to html as well"
  echo
  echo "       current working directory."
  echo
  exit 1
}

[ -z "$1" -o -z "$2" ] && usage

basename="$1"
shift

TMP_SH="/tmp/save-cmd-output-$$.sh"
echo "#!/bin/bash" > "$TMP_SH"
echo "$@" >> "$TMP_SH"
chmod +x "$TMP_SH"
OUTPUT="${basename}-$(date +%Y%m%d-%H:%M:%S).script"

cat "$TMP_SH" > "$OUTPUT"
echo >> "$OUTPUT"
script -a -c "$TMP_SH" "$OUTPUT"

