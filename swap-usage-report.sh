#!/bin/bash

COLUMNS=$(tput cols)

(
	cd /proc
	for pid in [0-9]*; do
  swapused=$(
		awk 'BEGIN { swap = 0 }
			/^VmSwap/ { swap = swap + $2 }
		END { print swap }' /proc/$pid/status 2>/dev/null || echo 0)
  if [ $swapused -gt 0 ]; then
		swapused_meg=$((swapused/1024))
		swapused_meg_total=$((swapused_meg_total+swapused_meg))
    #/bin/echo -e "${swapused_meg} M\t$(cat ${PROCESS}/cmdline)"
    printf "%.${COLUMNS}s\n" "${swapused_meg} M  ${pid}  $(cat /proc/${pid}/cmdline)"
  fi
done 
/bin/echo -e "${swapused_meg_total} M  All procs combined."
) | sort -n 

exit 0

# Alternative method:
# Note: This didn't seem to yield correct figures, only ~1289M while free
# report around 1900+ used.

(for PROCESS in /proc/*/; do
  swapused=$(awk '
		BEGIN { total = 0 } 
		/^Swap:[[:blank:]]*[1-9]/ { total = total + $2 } 
		END { print total }' ${PROCESS}/smaps 2>/dev/null || echo 0)
  if [ $swapused -gt 0 ]; then
		swapused_meg=$((swapused/1024))
		swapused_meg_total=$((swapused_meg_total+swapused_meg))
    /bin/echo -e "${swapused_meg} M\t$(cat ${PROCESS}/cmdline)"
  fi
done 
/bin/echo -e "${swapused_meg_total} M\tAll procs combined."
) | sort -n 
