#!/bin/bash

# A small script to easily change targets of a set of symlinks.
# Run the script, then edit the generated rename.sh to set the
# new targets of the files.

> rename.sh
> rename.sh.tmp

count=0
for i in *; do
	if [ -L "$i" ]; then
		count=$((count+1))
		c=$(printf %05d $count)
		ls -l "$i"
		stat "$i" | grep "File:" | \
			sed "s/^.*File: \`\(.*\)' -> \`\(.*\)'\$/NEWTARGET${c}=\"\2\"\t\t# \1/" >> rename.sh
		echo "ln -sfn \"\$NEWTARGET${c}\" \"$i\"" >> rename.sh.tmp
	fi
done

cat rename.sh.tmp >> rename.sh
echo "rm -f rename.sh rename.sh.tmp" >> rename.sh
echo "==>> generated script: rename.sh"
ls -l rename.sh
