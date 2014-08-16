#!/usr/bin/env bash
# Needs to run in bash as sh/dash doesn't support all this

# ANSI Color -- use these variables to easily have different color
#    and format output. Make sure to output the reset sequence after 
#    colors (f = foreground, b = background), and use the 'off'
#    feature for anything you turn on.

initializeANSI()
{
  esc="\e"

  blackf="${esc}[30m"   
  redf="${esc}[31m"   
  greenf="${esc}[32m"
  yellowf="${esc}[33m";   bluef="${esc}[34m";   purplef="${esc}[35m"
  cyanf="${esc}[36m";    whitef="${esc}[37m"
  
  blackb="${esc}[40m";   redb="${esc}[41m";    greenb="${esc}[42m"
  yellowb="${esc}[43m"   blueb="${esc}[44m";   purpleb="${esc}[45m"
  cyanb="${esc}[46m";    whiteb="${esc}[47m"

  boldon="${esc}[1m";    boldoff="${esc}[22m"
  italicson="${esc}[3m"; italicsoff="${esc}[23m"
  ulon="${esc}[4m";      uloff="${esc}[24m"
  invon="${esc}[7m";     invoff="${esc}[27m"

  reset="${esc}[0m"
}

rainbowify() {
	str="$1"
	rainbow[1]="$boldoff$redf"
	rainbow[2]="$boldon$redf"
	rainbow[3]="$boldoff$yellowf"
	rainbow[4]="$boldon$yellowf"
	rainbow[5]="$boldoff$greenf"
	rainbow[6]="$boldon$greenf"
	rainbow[7]="$boldoff$cyanf"
	rainbow[8]="$boldon$cyanf"
	rainbow[9]="$boldon$bluef"
	rainbow[10]="$boldoff$bluef"
	rainbow[11]="$boldon$purplef"
	rainbow[12]="$boldoff$purplef"
	total=${#rainbow[*]}
	#echo "[$str]"
	length=$(echo "$str" | wc -c)
	for i in {1..12}; do
		start=$(( (i-1)*length/total+1))
		end=$(( i*length/total ))
		#echo "i = $i, start = $start, end = $end"
		substr=$(echo "$str" | cut -b "$start-$end")
		#echo -n "$substr "
		echo -en "${rainbow[i]}${substr}"
	done
	echo -e $reset
}

bright_rainbowify() {
  str="$1"
  bright_rainbow[1]="$boldon$redf"
  bright_rainbow[2]="$boldon$yellowf"
  bright_rainbow[3]="$boldon$greenf"
  bright_rainbow[4]="$boldon$cyanf"
  bright_rainbow[5]="$boldon$bluef"
  bright_rainbow[6]="$boldon$purplef"
  total=${#bright_rainbow[*]}
  #echo "[$str]"
  length=$(echo "$str" | wc -c)
  for i in {1..6}; do
    start=$(( (i-1)*length/total+1))
    end=$(( i*length/total ))
    #echo "i = $i, start = $start, end = $end"
    substr=$(echo "$str" | cut -b "$start-$end")
    #echo -n "$substr "
    echo -en "${bright_rainbow[i]}${substr}"
  done
  echo -e $reset
}

# note in this first use that switching colors doesn't require a reset
# first - the new color overrides the old one.

initializeANSI

redf="${esc}[31m";  greenf="${esc}[32m";  yellowf="${esc}[33m";
bluef="${esc}[34m"; purplef="${esc}[35m"; cyanf="${esc}[36m";
boldon="${esc}[1m"; boldoff="${esc}[22m"

echo -e "Somewhere over the ${redf}_R_${yellowf}_AI_${greenf}_N_${cyanf}_B_${bluef}_O_${purplef}_W_${reset}"
echo -e "Somewhere over the ${boldon}${redf}_R_${yellowf}_AI_${greenf}_N_${cyanf}_B_${bluef}_O_${purplef}_W_${reset}"
echo -e "${yellowf}This is a phrase in yellow${redb} and red${reset}"
echo -e "${boldon}This is bold${ulon} this is italics${reset} bye bye"
echo -e "${italicson}This is italics${italicsoff} and this is not"
echo -e "${ulon}This is ul${uloff} and this is not"
echo -e "${invon}This is inv${invoff} and this is not"
echo -e "${yellowf}${redb}Warning I${yellowb}${redf}Warning II${reset}"
rainbowify "This is a long test string"
rainbowify "SOMEWHERE OVER THE RAINBOW"
rainbowify "SOMEWHERE OVER THE RAINBOW SOMEWHERE OVER THE RAINBOW SOMEWHERE OVER THE RAINBOW "
rainbowify "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
rainbowify "================================================================================="
rainbowify "_________________________________________________________________________________"
rainbowify "---------------------------------------------------------------------------------"
rainbowify "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"
rainbowify "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
rainbowify "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
rainbowify "................................................................................."
rainbowify ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
rainbowify "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
bright_rainbowify "This is a long test string"
bright_rainbowify "SOMEWHERE OVER THE RAINBOW"
bright_rainbowify "SOMEWHERE OVER THE RAINBOW SOMEWHERE OVER THE RAINBOW SOMEWHERE OVER THE RAINBOW "
bright_rainbowify "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
bright_rainbowify "================================================================================="
bright_rainbowify "_________________________________________________________________________________"
bright_rainbowify "---------------------------------------------------------------------------------"
bright_rainbowify "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"
bright_rainbowify "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
bright_rainbowify "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
bright_rainbowify "................................................................................."
bright_rainbowify ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
bright_rainbowify "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

for a in {4..80}; do
	s=""
	b=0
	while [ $b -le $a ]; do
		s="${s}@"
		b=$((b+1))
	done
	bright_rainbowify $s
done
