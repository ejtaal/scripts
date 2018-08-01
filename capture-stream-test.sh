#!/bin/sh

usage() {
  echo "Usage:"
  echo
  echo "  $0 \$url \$base-filename \$num-of-minutes-to-try"
  echo
}

ORIGURL="$1"
URL="$1"
BASENAME="$2"
EXT="${3:-asf}"

SLEEPTIME=10

startcommand=`date +%s`
while :; do
  echo "$(date) - Starting $(basename $0) $URL $BASENAME $TRYMIN"
  FULLPATH="${BASENAME}_$(date +"%Y-%m-%d-%H:%M:%S").${EXT}"
  echo "Saving to: $FULLPATH"
  mplayer -dumpstream "$URL" -dumpfile "$FULLPATH"

  EXITCODE=$?
  echo "EXITCODE = $EXITCODE"
  endcommand=`date +%s`
  fullsecondsran=$((endcommand-startcommand))
  days=$((fullsecondsran/86400))
  secondsran=$((fullsecondsran-(days*86400)))
  hours=$((secondsran/3600))
  secondsran=$((secondsran-(hours*3600)))
  mins=$((secondsran/60))
  secondsleft=$((secondsran-(mins*60)))
	echo
  echo "============================= $(date) ==================================="
	echo
  echo "The script has now run for [${days}d:${hours}h:${mins}m:${secondsleft}s]"
	if [ -f "$FULLPATH" ]; then
	  FILESIZE=$(ls -l "$FULLPATH" | awk '{print  $5}')
	  if [ $FILESIZE -gt 1024 ]; then
	    FAILURES=0
	    echo "More than 1k saved, assuming success, not wasting time and restarting immediately..."
	  else
	    FAILURES=$((FAILURES+1))
	    #echo "Less than 1k saved, assuming failure no. $FAILURES, trying again after $FAILURES x 10 seconds..."
			#if [ $FILESIZE -eq 127 -o $FILESIZE -eq 565 -o $FILESIZE -eq 429 ] && file "$FULLPATH" | grep -q 'ASCII text'; then
			if file "$FULLPATH" | grep -q ' text'; then
				# These are often files just containing the source mms:// url, adjust our url to it:
				NEWURL=$(grep 'ref href' "$FULLPATH" | cut -f 2 -d '"')
				if [ -n "$NEWURL" ]; then
					URL="$NEWURL"
				fi
	    	echo "127/565 byte file with url saved, deleting it. This is failure no. $FAILURES, trying again after $FAILURES seconds..."
	    	#sleep $((FAILURES*10))
				rm -vf "$FULLPATH"
	    	sleep $SLEEPTIME
			else
	    	echo "Less than 1k saved, assuming failure no. $FAILURES, trying again after $FAILURES seconds..."
	    	#sleep $((FAILURES*10))
	    	sleep $SLEEPTIME
			fi
	  fi
	else
		echo "File not present: $FULLPATH"
	fi
  
  if [ $FAILURES -gt 50 ]; then
    echo "Been failing 50 times in a row, that's enough!"
    break
  fi
  if [ $fullsecondsran -gt 14400 ]; then
    echo "Been running for more than 4 hours, that's enough!"
    break
  fi
done





