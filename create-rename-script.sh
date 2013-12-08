#!/bin/sh
#
# This script allows you to easily rename a large number of
# files. Run it with the names of the files you wish to rename
# as an argument. It creates a 'rename.sh' file which you can
# then edit with your favorite editor, allowing you to run your
# macros/search/replace etc. When done, run rename.sh and it
# takes care of business for you.
#
# License: BSD
# Copyright: (c) 2006-2014 Erik Taal <ejtaal@gmail.com>
#

> rename.sh
> rename.sh.tmp

count=1
if [ "$1" != "" ]; then
	for file in "$@"; do
	  MARKER=$(printf "%05d" ${count})
	  echo "NEW${MARKER}=\"$file\"" >> rename.sh
	  echo "ORIG${MARKER}=\"$file\"" >> rename.sh.tmp
	  echo "if [ \"\$NEW${MARKER}\" != \"\" -a \"\$NEW${MARKER}\" != \"\$ORIG${MARKER}\" ]; then mv -vi -- \"\$ORIG${MARKER}\" \"\$NEW${MARKER}\"; fi " >> rename.sh.tmp
	  count=$((count+1))
	done
else
	for file in *; do
	  MARKER=$(printf "%05d" ${count})
	  echo "NEW${MARKER}=\"$file\"" >> rename.sh
	  echo "ORIG${MARKER}=\"$file\"" >> rename.sh.tmp
	  echo "if [ \"\$NEW${MARKER}\" != \"\" -a \"\$NEW${MARKER}\" != \"\$ORIG${MARKER}\" ]; then mv -vi -- \"\$ORIG${MARKER}\" \"\$NEW${MARKER}\"; fi " >> rename.sh.tmp
	  count=$((count+1))
	done
fi

cat rename.sh.tmp >> rename.sh

echo "rm -f rename.sh rename.sh.tmp" >> rename.sh

echo "==>> generated script: rename.sh"
ls -l rename.sh
