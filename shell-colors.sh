#!/usr/bin/env bash
# Needs to run in bash as sh/dash doesn't support all this

# ANSI Color -- use these variables to easily have different color
#    and format output. Make sure to output the reset sequence after 
#    colors (f = foreground, b = background), and use the 'off'
#    feature for anything you turn on.

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

bright_rainbowify256() {
  str="$1"
##### dark purple blue teal green yellow orange red
rainbow256=( 53 89 125 161 197 
	198 199 200 201 165 129 93 57 
	63 69 33 27 21 20 26 32 39 45 51 50 44 43 37 30 29 28 34 40 46 82 
	118 154 190 226 
	220 214 208 202 
	166 130 94 52 88 124 160 196
	)
	#for k in ${rainbow256[*]}; do
	#	/usr/bin/printf "%b%s%b" "\e[38;5;${k}m" "${k}" "\e[0m"
	#done
	#echo
	#for k in ${rainbow256[*]}; do
	#	/usr/bin/printf "%b%s%b" "\e[38;5;${k}m" "#" "\e[0m"
	#done
	#echo
  
	total=${#rainbow256[*]}
  
	#echo "[$str]"
  length=$(echo "$str" | wc -c)
  for i in `seq 1 $total`; do
    start=$(( (i-1)*length/total+1))
    end=$(( i*length/total ))
    #echo "i = $i, start = $start, end = $end"
		if [ $i = $total ]; then
			#echo MARK
			end=
		fi
    substr=$(echo "$str" | cut -b "$start-$end")
		#echo "SUB = [$substr]"
    #echo -n "$substr "
    #echo -en "${bright_rainbow[i]}${substr}"
		j=$((i-1))
		/usr/bin/printf "%b%s" "\e[38;5;${rainbow256[j]}m" "${substr}" 
  done
  echo -e $reset
}
bright_rainbowify256 \
	"Now this is a way cooler way to print some text in a colour spectrum :)"

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
echo -e "${blackf}${redb}${invon}Black on red?"
rainbowify "This is a long test string"
rainbowify "SOMEWHERE OVER THE RAINBOW"
rainbowify "SOMEWHERE OVER THE RAINBOW SOMEWHERE OVER THE RAINBOW SOMEWHERE OVER THE RAINBOW "
#rainbowify "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
#rainbowify "================================================================================="
#rainbowify "_________________________________________________________________________________"
#rainbowify "---------------------------------------------------------------------------------"
#rainbowify "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"
#rainbowify "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
#rainbowify "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
#rainbowify "................................................................................."
#rainbowify ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
#rainbowify "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
#bright_rainbowify "This is a long test string"
#bright_rainbowify "SOMEWHERE OVER THE RAINBOW"
#bright_rainbowify "SOMEWHERE OVER THE RAINBOW SOMEWHERE OVER THE RAINBOW SOMEWHERE OVER THE RAINBOW "
#bright_rainbowify "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
#bright_rainbowify "================================================================================="
#bright_rainbowify "_________________________________________________________________________________"
#bright_rainbowify "---------------------------------------------------------------------------------"
#bright_rainbowify "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"
#bright_rainbowify "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
#bright_rainbowify "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
#bright_rainbowify "................................................................................."
#bright_rainbowify ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
#bright_rainbowify "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

for a in 10 20 30; do
	s=""
	b=0
	while [ $b -le $a ]; do
		s="${s}@"
		b=$((b+1))
	done
	bright_rainbowify $s
done


for i in {0..31}; do
	for j in {0..7}; do
		k=$((i*8+j))
		#printf "%b%*s" 12 "\x1b[38;5;${k}mcolour${k}\x1b[0m"
		#/usr/bin/printf "10. %b%s%b\n" "\e[38;5;11m" "test" "\e[0m"
		/usr/bin/printf "%b%*s%b" "\e[38;5;${k}m" 14 "colour${k} ### " "\e[0m"
		#/usr/bin/printf "%b%*s" 12 "\e[38;5;${k}m" "colour${k}\x1b[0m"
		#if [ $k -lt 10 ]; then
		#	echo -n '  '


		if [ $k -lt 17 -a $(((k+1)%8)) = 0 ]; then
			echo
		elif [ $k -gt 16 -a $(((k-15)%6)) = 0 ]; then
			echo
		fi
	done
	#if [ i
	#echo
done

