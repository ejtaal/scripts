#!/bin/bash
# This file was originally taken from iterm2 https://github.com/gnachman/iTerm2/blob/master/tests/24-bit-color.sh
#
#   This file echoes a bunch of 24-bit color codes
#   to the terminal to demonstrate its functionality.
#   The foreground escape sequence is ^[38;2;<r>;<g>;<b>m
#   The background escape sequence is ^[48;2;<r>;<g>;<b>m
#   <r> <g> <b> range from 0 to 255 inclusive.
#   The escape sequence ^[0m returns output to default

setBackgroundColor()
{
    #printf '\x1bPtmux;\x1b\x1b[48;2;%s;%s;%sm' $1 $2 $3
    #echo "RGB: $1 $2 $3"
    printf '\x1b[48;2;%s;%s;%sm' $1 $2 $3
}

resetOutput()
{
    echo -en "\x1b[0m\n"
}


bright_rainbow() {
	# degrees are 0-200
	# Calc loosely based on: 
	# 	https://github.com/FastLED/FastLED/wiki/FastLED-HSV-Colors
	deg=$1
	max=200
	r=0
	g=0
	b=0
	#if [ $deg -lt 96 ]; then
	#	g=$((255*deg/96))
	if [ $deg -lt 50 ]; then
		g=$((255*deg/50))
	elif [ $deg -gt 160 ]; then
		#b=$(( 255- (255 * (deg-160)/100)  ))
		b=255
	elif [ $deg -lt 96 ]; then
		g=255
	elif [ $deg -lt 128 ]; then
		g=255
		b=$(( 255 * (deg-96)/32 ))
	else
		# deg 128-160
		b=255
		g=$(( 255- (255 * (deg-128)/32) ))
	fi
	
	r_constant=220
	#if [ $deg -lt 33 ]; then
		#r=$(( 255 - (255-r_constant)*(deg)/32 ))
	if [ $deg -lt 51 ]; then
		r=255
	#elif [ $deg -gt 32 -a $deg -lt 65 ]; then
	#	r=$r_constant
	#elif [ $deg -gt 64 -a $deg -lt 96 ]; then
	elif [ $deg -lt 96 ]; then
		#r=$(( r_constant- (r_constant*(deg-64)/32)    ))
		r=$(( r_constant- (r_constant*(deg-64)/32)    ))
		r=$(( 255 - 255 * (deg-50)/32 ))
	elif [ $deg -gt 160 ]; then
		r=$((255*(deg-160)/(max-160)))
	fi
	echo $r $g $b 

}

# Gives a color $1/255 % along HSV
# Who knows what happens when $1 is outside 0-255
# Echoes "$red $green $blue" where
# $red $green and $blue are integers
# ranging between 0 and 255 inclusive
rainbowColor()
{ 
    let h=$1/43
    let f=$1-43*$h
    let t=$f*255/43
    let q=255-t

    if [ $h -eq 0 ]
    then
        echo "255 $t 0"
    elif [ $h -eq 1 ]
    then
        echo "$q 255 0"
    elif [ $h -eq 2 ]
    then
        echo "0 255 $t"
    elif [ $h -eq 3 ]
    then
        echo "0 $q 255"
    elif [ $h -eq 4 ]
    then
        echo "$t 0 255"
    elif [ $h -eq 5 ]
    then
        echo "255 0 $q"
    else
        # execution should never reach here
        echo "0 0 0"
    fi
}

for i in `seq 0 127`; do
    setBackgroundColor $i 0 0
    echo -en " "
done
resetOutput
for i in `seq 255 -1 128`; do
    setBackgroundColor $i 0 0
    echo -en " "
done
resetOutput

for i in `seq 0 127`; do
    setBackgroundColor 0 $i 0
    echo -n " "
done
resetOutput
for i in `seq 255 -1 128`; do
    setBackgroundColor 0 $i 0
    echo -n " "
done
resetOutput

for i in `seq 0 127`; do
    setBackgroundColor 0 0 $i
    echo -n " "
done
resetOutput
for i in `seq 255 -1 128`; do
    setBackgroundColor 0 0 $i
    echo -n " "
done
resetOutput

for i in `seq 0 2 127`; do
    setBackgroundColor `rainbowColor $i`
    echo -n " "
done
resetOutput
for i in `seq 255 -2 128`; do
    setBackgroundColor `rainbowColor $i`
    echo -n " "
done
resetOutput
for i in `seq 0 2 230`; do
    setBackgroundColor `rainbowColor $i`
    echo -n " "
done

resetOutput
echo Supposedly a better one:

#for i in `seq 1 4 200`; do
#    setBackgroundColor `bright_rainbow $i`
#    #echo -n " $i "
#    echo "$i: `bright_rainbow $i`"
#done

for i in `seq 1 1 200`; do
    setBackgroundColor `bright_rainbow $i`
    echo -n " "
done
resetOutput
for i in `seq 1 2 200`; do
    setBackgroundColor `bright_rainbow $i`
    echo -n " "
done
resetOutput
