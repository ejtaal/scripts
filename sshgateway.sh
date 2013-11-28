#!/bin/bash

DEST="$1"

persistcommand() {
  # If command takes less then LIMIT seconds, don't execute it again
  LIMIT=2
  # Wait DELAY seconds before running the command again
  DELAY=15
  FORCE="n"
  if [ "$1" = "-f" -o "$1" = "--force" ]; then
    FORCE="y"
    shift
  fi

  while :; do
    echo "Starting persistcommand:($*). Delay = $DELAY, limit = $LIMIT, force = $FORCE "
    date
    startcommand=`date +%s`
    "$@"
    EXITCODE=$?
    endcommand=`date +%s`
    secondsran=$((endcommand-startcommand))
    days=$((secondsran/86400))
    secondsran=$((secondsran-(days*86400)))
    hours=$((secondsran/3600))
    secondsran=$((secondsran-(hours*3600)))
    mins=$((secondsran/60))
    secondsleft=$((secondsran-(mins*60)))
    date
    echo "The command ran for [${days}d:${hours}h:${mins}m:${secondsleft}s]"
    if [ $EXITCODE -eq 0 ]; then
      if [ "$FORCE" = "y" ]; then
        echo "Seems like a normal exit, but forcing a resume of persistcommand:($*)."
      else
        echo "Seems like a normal exit, quitting persistcommand:($*)."
        break
      fi
    else
      echo "Exitcode was: $EXITCODE."
    fi
    if [ "$secondsran" -gt $LIMIT -o "$FORCE" = "y" ]; then
      echo "Running the command again after $DELAY seconds..."
      sleep $DELAY
    else
      echo "Command ran for less than $LIMIT seconds. Not trying it again. Exiting..."
      break
    fi
  done
}


persistcommand -f ssh $DEST

