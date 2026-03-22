#!/bin/bash

FILE="$1"
CONTEXT="$2"
GIVEN_COUNT="$3"

if [ -n "$GIVEN_COUNT" ]; then
	echo GIVEN_COUNT = $GIVEN_COUNT
	TOTAL_COUNT=$GIVEN_COUNT
else
	echo "Calculating line count first ..."
	TOTAL_COUNT=$(cat $FILE | wc -l)
	echo TOTAL_COUNT $TOTAL_COUNT
fi

:||{
	/*
 awk 'NR>=20 && NR<=25 || NR>=1 && NR<=3 || NR>=5 && NR<=7 { print NR ": " $0 } ' /etc/passwd
 */
}

AWK_SCRIPT="NR<=$CONTEXT || NR>=$((TOTAL_COUNT-CONTEXT))"

percent="$((TOTAL_COUNT/100))"
for p in {1..99}; do
	AWK_SCRIPT="$AWK_SCRIPT || NR>=$((p*percent)) && NR<=$((p*percent+CONTEXT))"
done

AWK_SCRIPT="$AWK_SCRIPT { print NR \" (\" int(NR/$percent) \"%): \" \$0 } "

#echo AWK_SCRIPT $AWK_SCRIPT

awk "$AWK_SCRIPT" "$FILE"
