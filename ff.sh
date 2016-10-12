#!/bin/bash

# Depends on: generic-linux-funcs.sh
if [ -f ~/scripts/generic-linux-funcs.sh ]; then
	. ~/scripts/generic-linux-funcs.sh
else
	echo generic-linux-funcs.sh not found :-/
	NOFUNCS=1
fi

for i in ~/firefoxes/*; do
	if [ -d "$i" ]; then
		j=$(basename $i)
		STABLE_FFS="$STABLE_FFS \"$j\" \"FF - $j\""
	fi
done

if [ "$1" = "" ]; then
	tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/ff-$$
	DIALOG=${DIALOG=dialog}
	DIALOG=gdialog
	echo "$DIALOG --clear --title \"Launch Firefox\" \
		--menu \"Available choices:\" 10 $((COLUMNS-4)) 20 \
			$STABLE_FFS"
	#read
	eval "$DIALOG --clear --title \"Launch Firefox\" \
		--menu \"Available choices:\" 30 80 20 \
			$STABLE_FFS" \
			2> $tempfile
	retval=$?
	choice=`cat $tempfile`
elif [ -d "/home/taal/firefoxes/$1" ]; then
	retval=0
	choice="$1"
else
	print "Profile directory /home/taal/firefoxes/$1 not found!"
	exit 1
fi


case $retval in
  0)
		PROFILE_PATH="/home/taal/firefoxes/$choice"
    echo "Launching '$choice' ..."
		case $choice in
			*-stable)
				FF_CMD="firefox -no-remote -P $choice"
				;;
			*-e10s)
				cd $PROFILE_PATH/.mozilla/firefox && rm -rf *.dev-edition-default
				DEFAULT="$(ls -1d *.default)"
				mv -vf profiles.ini profiles.ini.bak
				echo "[General]
StartWithLastProfile=1

[Profile0]
Name=$choice
IsRelative=1
Path=$DEFAULT
Default=1" > profiles.ini
				FF_CMD="/home/taal/.local/share/umake/bin/firefox-developer --no-remote --profile $DEFAULT"
				#FF_CMD="/home/taal/.local/share/umake/bin/firefox-developer --no-remote -P $choice"
				#FF_CMD="/home/taal/.local/share/umake/bin/firefox-developer --no-remote -P"
				;;
esac

perl -pi.bak -e "s/^Name=.*$/Name=$choice/" "${PROFILE_PATH}/.mozilla/firefox/profiles.ini"
SESSIONSTORE="${PROFILE_PATH}/.mozilla/firefox/$DEFAULT/sessionstore.js"
SESSIONSTORE_BAK="${PROFILE_PATH}/.mozilla/firefox/$DEFAULT/sessionstore-backups/"
STAMP="$(date -r "$SESSIONSTORE" +%Y%m%d-%H%M)"
cp -v "$SESSIONSTORE" "$SESSIONSTORE_BAK/sessionstore.js.$STAMP"

if [ ! -L ${PROFILE_PATH}/Desktop ]; then
	mv ${PROFILE_PATH}/Desktop ${PROFILE_PATH}/Desktop.bak
	ln -s ~/Desktop ${PROFILE_PATH}/Desktop
fi

if [ ! -L ${PROFILE_PATH}/Downloads ]; then
	mv ${PROFILE_PATH}/Downloads ${PROFILE_PATH}/Downloads.bak
	ln -s ~/Downloads ${PROFILE_PATH}/Downloads
fi

if [ ! -L ${PROFILE_PATH}/.cache ]; then
	mv ${PROFILE_PATH}/.cache ${PROFILE_PATH}/.cache.bak
	mkdir -p /tmp/taal/.cache
	ln -s /tmp/taal/.cache ${PROFILE_PATH}/.cache
fi

		echo eval\'ing "HOME=$PROFILE_PATH $FF_CMD"
		eval "HOME=$PROFILE_PATH $FF_CMD"
		;;
  1)
    echo "Cancel pressed.";;
  255)
    echo "ESC pressed.";;
esac

echo retval = $?
echo tempfile:
cat "$tempfile"
