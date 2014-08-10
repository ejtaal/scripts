#!/bin/bash

char=( 6a 6b 6c 6d 6e 71 74 75 76 77 78 )
for i in ${char[*]}
do
	printf "0x$i \x$i \e(0\x$i\e(B\n"
done
