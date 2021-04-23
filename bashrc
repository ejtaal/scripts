#!/bin/bash

# My .bashrc full of magical bash wizardry...well sort of.
# Depends on: generic-linux-funcs.sh

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

if [ -f ~/scripts/generic-linux-funcs.sh ]; then
	. ~/scripts/generic-linux-funcs.sh
else
	echo generic-linux-funcs.sh not found :-/
	NOFUNCS=1
fi

# User specific aliases and functions
umask 022

### Part 1. aliases ###
# Now exported externally due to popular proliferation of zsh. Oh it's not so bad.
if [ -r ~/.common_sh_funcs ]; then
	. ~/.common_sh_funcs
fi

### Part 2. Variables ###

# Dynamically build path:
ADDPATH="/sbin:/usr/sbin:/usr/local/sbin:/usr/X11R6/bin:/usr/local/bin:$HOME/bin:$HOME/scripts:$HOME/repos/quiver/scripts:$HOME/repos/webdavmeta"
#if [ -d "${HOME}/scripts/" ]; then
#  for dir in `find "${HOME}/scripts/" -type d -regex "[^.]*"`; do
#    ADDPATH="${ADDPATH}:$dir"
#  done
#fi

#export PS1='\u@\h:\w> '
#export TERM="linux"
#unset LS_COLORS
#eval $(dircolors)
eval $(dircolors ~/scripts/dircolors.ansi-dark)

export AGENTFILE="/home/taal/.ssh/agent.rc"

# Check for WSL:
if [ -x "$(which powershell.exe 2> /dev/null)" ]; then
	if "$(which powershell.exe)" 'ps' | grep -q Xming; then
		# Yay, got Xming
		DISPLAY=0:0
	fi
fi

export EDITOR="vim"
export PAGER="less"
export PS1_DEFAULT="$PS1"
# Highlight in green, 32 -\
export GREP_COLORS='ms=01;32:mc=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36'
export HISTCONTROL="ignorespace"
export HISTFILESIZE=99000
export HISTSIZE=99000
export HISTTIMEFORMAT="%Y-%m-%d--%H:%M "
export LESS='--ignore-case --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --tabs=4 --no-init --window=-3'
export PATH="$PATH:${ADDPATH}"
export SVKDIFF="/usr/bin/diff -u"
export STATUSLINE_DELAY=10
export SUDO_EDITOR='rvim'
export USERNAME=$(whoami)
export WORKON_HOME=~/virtualenvs

shopt -s histappend
shopt -s checkwinsize
# Disable super annoying broken per-app smarty pants tab completion..Ugh
shopt -u progcomp

# Fixes tab completion for: $ coolcmd --first-opt=/a/file/name<TAB> -- Hmm not really
complete -D -o default

# Alternative to putting things in .inputrc we can define readline options using 'bind' within bash:
bind 'set completion-ignore-case On'
bind 'set completion-map-case On'
bind 'set completion-prefix-display-length 3'
bind 'set mark-symlinked-directories on'
bind 'set bell-style none'

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

#if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
#    . /etc/bash_completion
#fi
	

### End of variables ###

### Part 3. Subroutines ###

normalprompt() {
	export PROMPT_COMMAND=""
	#export PS1='\u@\h:\w> '
	export PS1="$PS1_DEFAULT"
}

# The preexec stuff here allows you to set a variable
# before a command starts. I use it to set a timestamp
# so we can calc how long a command ran.
preexec () { 
	# Show system info only after first command has finished.
#	if [ "$BASH_SHOW_SYSINFO" = "0" ]; then
#		BASH_SHOW_SYSINFO=1
#	elif [ "$BASH_SHOW_SYSINFO" = "1" ]; then
#		echo "$(system_info)" "${dist_info}"
#		BASH_SHOW_SYSINFO=2
#	fi
	#echo "BASH_COMMAND_START=$BASH_COMMAND_START"
	
	# Flush history to disk (command might crash your shell or something you know)
	history -a

	CMD="${1%% *}"
	if [ -n "$CMD" ]; then
		SCREENTITLE=$(echo "$@" | sed -e "s# $HOME# ~#" | sed -e 's/^\(............\).*/\1/');
		echo "$TERM" | grep -q 'screen' && echo -ne "\ek${SCREENTITLE}\e\\"
	fi
	
	if [ "$WINDOWTITLE_SETTABLE" = "y" ]; then
		local title="${1:0:20}"
		echo -n -e "\e]0;$title | $(whoami) @ $HOSTNAME | $PROMPTDIR   | \a";
	fi
	
	[ -z "$BASH_COMMAND_START" ] && export BASH_COMMAND_START=$(date +"%s%3N")
}

preexec_invoke_exec () {
    [ -n "$COMP_LINE" ] && return  # do nothing if completing
    local this_command=`history 1 | sed -e "s/^[ ]*[0-9]*[ ]*[0-9:\-]*[ ]*//g"`;
    preexec "$this_command"
		
}
trap 'preexec_invoke_exec' DEBUG

prompt_command() {
  # First get the last exit code to display later
  LASTEXIT=$?


	if [ "$last_username" != $USERNAME ]; then
		# We've switched users, update PS1 if necessary
		# Note: this also allows 3rd party mods of PS1 by software
		# such as virtualenvwrapper.
		indentcolour="$boldon$cyanf"
	  if [ $USERNAME = "root" -o "$UID" = 0 ]; then
			usercolour="$boldon$redf"
			indentcolour="$boldon$redf"
			prompt_char='#'
  	else
			usercolour="$boldon$greenf"
			prompt_char='$'
  	fi;
		#echo PS1="[$PS1]"
		PS1="\[${indentcolour}\]${prompt_char}\[${reset}\] "
	fi
	last_username=$USERNAME

	echo -ne "${indentcolour}┌"
	i=2
	while [ $i -lt $COLUMNS ]; do
		i=$((i+1))
		echo -ne "─"
	done
	echo -e "┐${reset}"
	# Ph34r |\/|y l33t B45h |-|A<k3r Pr0|\/|p7 ;)


	# Load current history:
	# Disabled now since actually this is annoying as often i want 
	# to run the previous command of a terminal and not the previous
	# system-wide command.
	#history -n

  #COLUMNSLEFT=$(($COLUMNS-5))
  #MYPWD=$(pwd | sed -e "s#^$HOME\$#$HOME (~ HOME)#" -e "s#^$HOME/#~/#")
  MYPWD=$(pwd | sed -e "s#^$HOME\$#$HOME (~ HOME)#" -e "s#^$HOME/#~/#")
	PROMPTDIR="$MYPWD"
  PWDLENGTH=${#MYPWD}
	#if [ "$PWDLENGTH" -lt "$COLUMNSLEFT" ]; then
	#  PROMPTDIR="$MYPWD"
	#else
	#  # There's not enough space to print the pwd, so print equal parts of the left and right side
	#  PROMPTDIR="$(echo "$MYPWD" | cut -b -$((COLUMNSLEFT/2-2)))...$(echo "$MYPWD" | cut -b $((PWDLENGTH-(COLUMNSLEFT/2)+2))-)"
	#fi
  # Set a nicer window title for screen
  # If we are in konsole, ssh or xterm
	if [ "$WINDOWTITLE_SETTABLE" = "y" ]; then
    # Set konsole window title
    echo -n -e "\e]0;$(whoami)@$HOSTNAME | $PROMPTDIR   | \a";
  fi
  
	indent="│"
	coloured_indent="${indentcolour}${indent}${reset}"
	echo -ne "${coloured_indent} "
	line2="${indent} "
	echo -n -e ${boldon}
  # Be optimistic :D
	smiley=":)"
	smiley_color="${boldon}${greenf}"
	if [ $LASTEXIT -ne 0 ]; then
  	# If last command was successful
    smiley=":("
		smiley_color="${boldon}${redf}"
  fi
  # Echo smiley in appropiate color + numeric exit code
	echo -ne "${smiley_color}${smiley}${reset} $LASTEXIT | ";
	line2="${line2}${smiley} $LASTEXIT | "
	
	BASH_COMMAND_END=$(date +"%s%3N")
	BASH_COMMAND_RAN=`human_time $BASH_COMMAND_START $BASH_COMMAND_END`
	
	echo -n "${BASH_COMMAND_RAN} | "
	line2="${line2}${BASH_COMMAND_RAN} | "
	export BASH_COMMAND_START=""
	#echo
  
	cur_date="$(date +'%Y/%m/%d, %a, %H:%M:%S')"
	echo -n "${cur_date} | "
	line2="${line2}${cur_date} | "

	#echo -ne "${boldon}${cyanf}${indent}${reset} "
	#echo MARK
	#uptime_etc="$(uptime | sed -e 's/^.*up */+/' -e 's/ days*, */d:/g' -e 's/[ \t]*users*.*/u/')"
	uptime_etc="$(uptime | sed \
		-e 's/^.*up */+/' \
		-e 's/ days*, */d:/g' \
		-e 's/ mins*,/m /g' \
		-e 's/[ \t]\([0-9]*\)* users*,/\1u/' \
		-e 's/ load average:/|/' \
		-e 's/ \([0-9]*\.[0-9]\)[0-9],*/ \1/g'
	)"
	echo -n "${uptime_etc}"
	line2="${line2}${uptime_etc}"
	CURPOS=${#line2}
	SPACELEFT=$((COLUMNS-CURPOS))

	# Right justify mem, battery and VMs info:
	right1_info=
	right1_bare=

	MemTotal=$(grep ^MemTotal: /proc/meminfo | awk '{ print $2 }')
	MemAvailable=$(grep ^MemAvailable: /proc/meminfo | awk '{ print $2 }')
	SwapTotal=$(grep ^SwapTotal: /proc/meminfo | awk '{ print $2 }')
	SwapFree=$(grep ^SwapFree: /proc/meminfo | awk '{ print $2 }')

	mem_threshold_warn=25
	mem_threshold_crit=10
	ram_free=$((100*MemAvailable / MemTotal))
	if [ "$SwapTotal" != 0 ]; then
		swap_free=$((100*SwapFree / SwapTotal))
	else
		swap_free='-'
	fi
	#echo $swap_free $ram_free
	
	ram_color="${greenf}"
	if [ $ram_free -le $mem_threshold_crit ]; then
		ram_color="${redf}"
	elif [ $ram_free -le $mem_threshold_warn ]; then
		ram_color="${yellowf}"
	fi
	swap_color="${greenf}"
	if [ "$swap_free" = '-' ]; then
		swap_color="${ram_color}"
	else
		if [ $swap_free -le $mem_threshold_crit ]; then
			swap_color="${redf}"
		elif [ $swap_free -le $mem_threshold_warn ]; then
			swap_color="${yellowf}"
		fi
	fi

	right1_info="${right1_info}MEM:${boldon}${ram_color}${ram_free}%${reset}/${boldon}${swap_color}${swap_free}%${reset} "
	right1_bare="${right1_bare}MEM:${ram_free}%/${swap_free}% "


	batno=0
	for i in /sys/class/power_supply/BAT*; do
		#echo $i
		if [ ! -d "$i" ]; then
			continue
		fi
		batno=$((batno+1))
		bat=$(basename $i)
		#full=$(cat $i/charge_full)
		#now=$(cat $i/charge_now)
		#model=$(cat $i/model_name)
		#tech=$(cat $i/technology)
		#current=$(cat $i/current_now)
		status=$(cat $i/status)
		#perc=$((current*100/full))
		if [ -f $i/capacity ]; then
			cap=$(cat $i/capacity)
		else
			cap=1
		fi
		if [ "$status" = 'Discharging' ]; then
			bat_color="${yellowf}"
			if [ "${cap}" -le 20 ]; then
				bat_color="${redf}"
			fi
		else
			bat_color="${greenf}"
		fi
		#if [ "$batno" = '1' ]; then
			#right1_info=' | '
			#right1_bare=' | '
			#line2="${line2} | "
		#fi
		right1_info="${right1_info}BAT:${boldon}${bat_color}${cap}%${reset}"
		right1_bare="${right1_bare}BAT:${cap}%"
		#line2="${line2} ${cap}%"
	done

	NUM_VMS=$(pgrep -f "(vmware-vmx|VirtualBox.*startvm|qemu-kvm)" | wc -l)
	if [ "$NUM_VMS" -gt 0 ]; then
		if [ -n "${right1_info}" ]; then
			right1_info="${right1_info} "
			right1_bare="${right1_bare} "
		fi
		right1_info="${right1_info}VMs:${boldon}${cyanf}$NUM_VMS${reset}"
		right1_bare="${right1_bare}VMs:$NUM_VMS"
	fi

	#right1_bare=$(echo "$right1_info" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g")

	SPACELEFT=$((SPACELEFT-${#right1_bare}))
	#echo "${right1_bare}" ${#right1_bare}

	i=2
	while [ $i -lt $SPACELEFT ]; do
		i=$((i+1))
		echo -ne " "
	done
	echo -en "$right1_info "
	echo -e "${coloured_indent}"
	echo -ne "${coloured_indent} "
	line3="${indent} "
  # Echo ' username[tty]@hostname(uname) | time | '
  echo -n -e "$boldon$usercolour$USERNAME${reset}@${boldon}${HOST_COLOR}$HOSTNAME${reset} $PROMPTDIR "
	line3="${line3}$USERNAME@$HOSTNAME $PROMPTDIR "
	CURPOS=${#line3}
	SPACELEFT=$((COLUMNS-CURPOS))
	#echo SPACELEFT = $SPACELEFT
	# this sets $if_gateway_info
	get_default_if
	MOREINFO="$os_icon $os_release $if_gateway_info"
	MOREINFO_BARE="$os_icon $os_release $if_gateway_info_bare"
	XINFO=""
	if [ -n "$DISPLAY" ]; then
		MOREINFO="$MOREINFO X"
		MOREINFO_BARE="$MOREINFO_BARE X"
		XINFO=" $boldon${yellowf}X$reset"
	fi
	#echo MARK
	#echo MOREINFO = $MOREINFO
	#echo MOREINFO_BARE = $MOREINFO_BARE
	MOREINFOLENGTH=${#MOREINFO_BARE}
	FILLERSPACE=$((SPACELEFT-MOREINFOLENGTH))
	i=2
	while [ $i -lt $FILLERSPACE ]; do
		i=$((i+1))
		echo -ne " "
	done
	echo -e "${os_color}$os_icon $os_release${reset} $if_gateway_info${XINFO} ${coloured_indent}"

	if [ "$INSIDE_SCREEN" = 'y' ]; then
		SCREENTITLE=$(pwd | sed "s#^$HOME#~#" | sed 's/^\(............\).*/\1/')
  	#echo -ne "\033k$SCREENTITLE\033\134";
  	echo -ne "\033k$SCREENTITLE\033\\";
	fi
	if [ -n "$TMUX_PANE" ]; then
		TMUX_PANE_TITLE=$(pwd | sed "s#^$HOME#~#" | sed 's/^\(............\).*/\1/')
		#ps h -o cmd -q $PPID | grep script
		tmux rename-window "$TMUX_PANE_TITLE"
	fi
}

statusline() {
	# Do some clever byobu like magic in here.
	# Better yet, source byobu's scripts and use their output
	shopt -s huponexit
	while sleep $STATUSLINE_DELAY; do
		#echo -en "${EMB}[${NONE}${NEW_PWD}${EMB}] ${GIT_BRANCH}${SVN_REV}${CURRENT_RV>
		write_statusline "==>> $(date) My super cool status bar, \$PIPO = $PIPO <<=="
	done
}

write_statusline() {
		lines=`tput lines`
		cols=`tput cols`
		tput sc
		#scroll_region="0 $((lines - 2))"
		scroll_region="0 $((lines - 3))"
		tput csr $scroll_region
		non_scroll_line=$((lines - 2))
		tput cup $non_scroll_line 0
		echo -e "${1}"
		echo -en "${2}"
		tput rc
}

niceprompt() {
	#rainbowify "Access granted. Welcome Mr.T_cpdump :)"
	bright_rainbowify256 "Access granted. Welcome Mr.T_cpdump :)"
	# Set up ssh keys if present
	find_ssh_agent
	if [ -n "$DISPLAY" ]; then
		xset-fast-keyboard
	fi
# Now launch the statusline in the background
	#statusline &
	#write_statusline "[...gathering system information...]"
	export TERM=xterm-256color
	#dist_info=$(get_basic_dist_info)
	get_basic_dist_info

	tty=$(tty | sed -e 's#^/dev/##')
	COLUMNS=${COLUMNS:-80}
  HOSTNAME=$(echo ${HOSTNAME%%\.*} | tr A-Z a-z)
  HOST_COLOR="${yellowf}"
	if [ -n "$VM_TYPE" ]; then
  	HOST_COLOR="${cyanf}"
  	HOST_COLOR="$VM_COLOR"
	fi

	INSIDE_SCREEN=n
  if echo "$TERMCAP $TERM" | grep -q 'screen'; then
		INSIDE_SCREEN=y
	fi
  
	if [ -n "$SSH_CLIENT" -o -n "$KONSOLE_DCOP" -o "$TERM" = "xterm" -o "$TERM" = "xterm-color" ]; then
		WINDOWTITLE_SETTABLE="y"
	fi
	
	export PROMPT_COMMAND="prompt_command"
	export PS1="> "
	export PS2='...> '
}

konsole_title() {
	# TODO: This can be made without sed right?
	# Prepare nice directory
	CURDIR=$(pwd | sed -e 's#\(/[^\/]*/[^\/]*\)/.*/\([^\/]*/[^\/]*\)\$#\1...\2#g');  
	# If we are in konsole or ssh
	if [ -n "$SSH_CLIENT" -o -n "$KONSOLE_DCOP" ]; then                               
		# Set konsole window title
		echo -ne "\e]0; :::   $@   ::: | ${USER} @ ${HOSTNAME} | $CURDIR   | \a";                                     
	fi
	SCREENTITLE=$(echo "$@" | sed -e "s# $HOME# ~#" | sed -e 's/^\(............\).*/\1/');
	echo "$TERM" | grep -q 'screen' && echo -e "\ek${SCREENTITLE}\e\\"
	"$@"
}

loadsshkeys() {
	echo "*** Loading ssh keys into the agent ***"
	for key in $(grep -rl 'PRIVATE KEY' $HOME/.ssh/ | sort ); do
		if [ -f "$key" ]; then
			if [ -f "${key}.pub" ]; then
				echo -n "Key comment: "
				awk '{ print $3 }' < "${key}.pub"
			fi
			ssh-add "$key" 2> /dev/null && echo "Key '$key' added OK"
		fi
	done
}

find_ssh_agent() {
	if [ -n "$SSH_AGENT_PID" ] && [ -r /proc/$SSH_AGENT_PID/cmdline ] && grep -q x-session-manager /proc/$SSH_AGENT_PID/cmdline; then
		# Unhelpful, nonfunctioning, script breaking garbage!
		#unset SSH_AGENT_PID
		unset SSH_AUTH_SOCK
	fi
	# Check for any available ssh-agents that contains keys, and try $SSH_AUTH_SOCK 
	# first because ssh -A sets that. If it's set do we want to load local keys as well? Hmm
	for agent in $SSH_AUTH_SOCK /tmp/ssh-*/agent.*; do
		export SSH_AUTH_SOCK=$agent
		# If loaded keys found then use that agent
		ssh-add -l | egrep -q "( |)[0-9][0-9]:" && break
		echo SSH_AUTH_SOCK=$agent
		ssh-add -l
		SSH_AUTH_SOCK=
	done
	# If no suitable agent was found then run the ssh-agent 
	# and add my ssh-key(s), but only if we're on a tty (to
	# stop this popping up before logging in to KDE
	# and then only if there actually are keys to add
	if tty > /dev/null 2>&1; then
		if [ -z "$SSH_AUTH_SOCK" -a -d "$HOME/.ssh/" ] && grep -qrl 'PRIVATE KEY' $HOME/.ssh/; then
			eval $(ssh-agent) > /dev/null
			unset SSH_ASKPASS
			loadsshkeys
		fi
	fi
	ssh-add -l 2> /dev/null | egrep -q "( |)[0-9][0-9]:" && \
			{ echo -n "SSH agent $SSH_AUTH_SOCK ($SSH_AGENT_PID): "; ssh-add -l | awk '{ print $3 }' | xargs; }
}

ctd() {
	sudo tcpdump "$@" \
		| tcpdump-colorize.pl
}

vdiff() {
	TMPDIFF="/tmp/vdiff-$USER-diff.$$"
	R=
	if [ -d "$1" ]; then
		R="-r"
	fi
	B=
	if [ "$1" = "-b" ]; then
		B="-b"
		shift
	fi

	MINPLUS=$(diff -u ${R} ${B} "$1" "$2" | grep "^[-+]" | grep -v "^---\|^+++" | cut -b 1 | sort | uniq -c | xargs echo)
	echo "# $MINPLUS" > "$TMPDIFF"
	echo "# diff -u ${R} ${B} " >> "$TMPDIFF"
	diff -u ${R} ${B} "$1" "$2" >> "$TMPDIFF"
	echo '# vim:ft=diff:syntax=diff' >> "$TMPDIFF"
	vim -R -c 'se ts=2' -c 'se ft=diff ro nomod ic' -c 'nmap q :q!<CR>' \
		"$TMPDIFF"
}

wakeup() {
	# Get wol from:
	# wget http://www.gcd.org/sengoku/docs/wol.c
	# gcc -o wol wol.c
	
	if [ -x /usr/bin/wakeonlan ]; then
		WAKE="/usr/bin/wakeonlan -i"
	elif [ -x /usr/local/bin/wol ]; then
		if wol 2>&1 | grep -qi Sengoku; then
			WAKE="/usr/local/bin/wol"
		else
			WAKE="/usr/local/bin/wol -v -i"
		fi
	else
		echo "Warning: couldn't find wol/wakeonlan program."
		return 1
	fi
	
	case "$1" in
		sr|stingray)
			$WAKE 18:67:b0:30:e4:2a
			;;
		*)
			echo "!! Host not recognized"
			return 1
			;;
	esac
}

delsshkey() {
	[ "$1" -lt 1 ] && {
		echo "please give me the line number of the offending key...";
		return 1;
	}
	KH="$HOME/.ssh/known_hosts"
	BAK="$HOME/.ssh/known_hosts.bak"
	\cp -f $KH $BAK
	cat $BAK | sed -n $1'!p' > $KH
}

keepalive() {
	DELAY=${1:-60}
	while :; do
		echo -n "Keeping your connection alive every $DELAY seconds! - "; date; sleep $DELAY;
	done
}

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
		#secondsran=$((endcommand-startcommand))
		readable_string=`human_time startcommand $endcommand`
		days=$((secondsran/86400))
		secondsran=$((secondsran-(days*86400)))
		hours=$((secondsran/3600))
		secondsran=$((secondsran-(hours*3600)))
		mins=$((secondsran/60))
		secondsleft=$((secondsran-(mins*60)))
		date
		echo "The command ran for [${readable_string}]"
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

human_time() {
	#echo human_time "[$*]"
	# Convert a number of (milli)seconds to something more readable by hoo-maans
	START=$1
	END=$2
	if [ "${#START}" = 19 ]; then
		# This is a duff version of date which gives %3N as 9 figures >_<
		# I.e. 1430387434000000374 i.s.o. 1430387434374, doh!
		# Remove the extra 6 zeros
		START=${START/000000/}
		END=${END/000000/}
	fi

	if [ "${#START}" = 13 ]; then
		# We've been given millisecs (length of 10 - 7 = 3)
		seconds=$(($END-$START))
		msecs="$((seconds%1000))"
		#echo "seconds $seconds"
		if [ $msecs -lt 100 ]; then pad='0'; fi
		if [ $msecs -lt 10 ]; then pad='00'; fi
		msecs=".${pad}$((seconds%1000))"
		seconds=$(( seconds / 1000))
	else
		seconds="$START"
	fi
	#echo "seconds $seconds msecs $msecs"
	days=$((seconds / 86400))
	seconds=$((seconds % 86400))
	hours=$((seconds / 3600))
	seconds=$((seconds % 3600))
	mins=$((seconds / 60))
	if [ $days -gt 0 ]; then final="${days}d:"; fi
	if [ $hours -gt 0 ]; then final="${final}${hours}h:"; fi
	if [ $mins -gt 0 ]; then final="${final}${mins}m:"; msecs=; fi
	secondsleft="$((seconds % 60))${msecs}s"
	echo "${final}${secondsleft}"
}

multitail-cut() {
	MULTITAIL="multitail "
	#TWOLINES=$(($COLUMNS*2))
	for logfile in "$@"; do
		#MULTITAIL="${MULTITAIL}-l 'tail -f $logfile | cut -b-$TWOLINES' "
		#MULTITAIL="${MULTITAIL}-l 'tail -f $logfile | perl -pi -e 's/.*\.(.*\..*) - - \[(.*?) \+\d+\]/\$2 \$1/g' | cut -b-$COLUMNS' "
		#MULTITAIL="${MULTITAIL}-l 'tail -f $logfile | perl -pi -e \"s/.*\.(.*\..*) - - \[(.*?) \+\d+\].*GET /\\\$2 \\\$1 \\\"/g\" | cut -b-$COLUMNS'"
		MULTITAIL="${MULTITAIL}-l 'tail -f $logfile | cut -b-$COLUMNS' "
	done
	echo "==>> Using the following multitail command:"
	echo "     $MULTITAIL"
	sleep 1
	eval "$MULTITAIL"
}
	
ltt() {
	ls -lartF "$@" | tail -$((LINES-6))
}

add-ssh-pubkey() {
	cat $HOME/.ssh/id_*.pub | \ssh "$1" "cat >> .ssh/authorized_keys"
}

get_default_if() {
	while read -a rtLine ;do
		# In case there's no gateway configured, just grab any configured device
		# Alternatively, maybe look at /proc/net/arp?
		device=${rtLine[0]}
  	if [ ${rtLine[1]} == "00000000" ] && [ ${rtLine[7]} == "00000000" ] ;then
      hexToIp default_gateway ${rtLine[2]}
			#echo $netInt
			#echo "addrLine = [$addrLine]"
			last_2_digits=${default_gateway#[0-9]*.[0-9]*.}
			last_digit=${default_gateway#[0-9]*.[0-9]*.[0-9]*.}
			#device=${rtLine[0]}
			break
		fi
	done < /proc/net/route
	#echo default_gateway = $default_gateway device = $device
	#if_ip=$(ip addr show dev $device | awk -F'[ /]*' '/inet /{print $3;exit}')
	# Read them all in an array, if more than 1
	if [ "$device" = "Iface" ]; then
		if_ip="x.x.x.x"
		last_digit="x"
	else
		if_ips=($(ip addr show dev $device | awk -F'[ /]*' '/inet /{print $3}'))
		if_ip=${if_ips[0]}
		#if_ip=$(ip addr show dev $device | awk -F'[ /]*' '/inet /{print $3}')
		first_3_if_ip=${if_ip%.[0-9]*}
		
		if [ ${#if_ips[@]} -gt 1 ]; then
			for (( i=1; i<${#if_ips[@]}; i++ )); do
				alt_ip=${if_ips[$i]}
				first_3_alt_ip=${if_ips[$i]%.[0-9]*}
				last_digit_alt_ip=${alt_ip#[0-9]*.[0-9]*.[0-9]*.}
				#mydebug alt_ip first_3_alt_ip last_digit_alt_ip first_3_if_ip
				if [ "$first_3_if_ip" = "$first_3_alt_ip" ]; then
					if_ip="$if_ip +${last_digit_alt_ip}"
				else
					if_ip="$if_ip $alt_ip"
				fi
			done
		fi
	
	fi
	first_3_gateway=${default_gateway%.[0-9]*}
	#arrow=">"
	arrow="→"
	if [ "$first_3_if_ip" = "$first_3_gateway" ]; then
		if_gateway_info="${if_ip} $arrow${last_digit}"
	else
		# Could be none found:
		if [ -z "${last_2_digits}" ]; then
			last_2_digits='_'
		fi
		if_gateway_info="${if_ip} $arrow${last_2_digits}"
	fi

	# Other ips active:
	other_ips=$(ip addr show  | egrep -v "($device|127.0.0.1)" | awk -F'[ /]*' '/inet /{print $3}' | xargs echo -n)
	if [ -n "$other_ips" ]; then
		if_gateway_info="$other_ips / $if_gateway_info"
	fi
	if_gateway_info="| $if_gateway_info"

# This is a bit too much info and often spills over
###	open_ports=$(awk '$4 == "0A" { split( $2, fields, ":"); a[strtonum("0x" fields[2])]++ } END { i=1; for (b in a) { SEP = (i++ < length(a) ? " " : "\n"); printf( "%s%s", b, SEP); }}' /proc/net/tcp{,?})
###	open_ports_udp=$(awk '$4 == "07" { split( $2, fields, ":"); a[strtonum("0x" fields[2])]++ } END { i=1; for (b in a) { SEP = (i++ < length(a) ? " " : "\n"); printf( "%s%s", b, SEP); }}' /proc/net/udp{,?})
###	
###	if [ -n "$open_ports_udp" ]; then
###		open_ports_udp=" ${open_ports_udp}"
###	fi
###	
###	if_gateway_info_bare="| L:$open_ports$open_ports_udp $if_gateway_info"
###	if_gateway_info="| L:$boldon$yellowf$open_ports$greenf$open_ports_udp$reset $if_gateway_info"

	if_gateway_info_bare="$if_gateway_info"

}

ffp() {
	FF_PROFILE_INI=~/.mozilla/firefox/profiles.ini
	FF_EXE=/usr/bin/firefox
	FF_PROFILE_DIR="$(dirname $FF_PROFILE_INI)"

	# Called via niceprompt() -> get-basic-sysinfo() but we need it here if used by itself
	vm_check
	if [ "$VM_TYPE" = "WSL" ]; then
		# Look in windows profiles:
		FF_PROFILE_INI="$WINDOWS_HOME/AppData/Roaming/Mozilla/Firefox/profiles.ini"
		FF_EXE="/mnt/c/Program Files/Mozilla Firefox/firefox.exe"
		FF_PROFILE_DIR="$(dirname $FF_PROFILE_INI)/Profiles"
	elif [ "$VM_TYPE" = "MINGW" ]; then
		# Look in windows profiles:
		FF_PROFILE_INI="$HOME/AppData/Roaming/Mozilla/Firefox/profiles.ini"
		FF_EXE="/c/Program Files/Mozilla Firefox/firefox.exe"
		FF_PROFILE_DIR="$(dirname $FF_PROFILE_INI)/Profiles"
	fi
	
	if [ -z "$1" ]; then
		echo "Available profiles ( in $FF_PROFILE_INI ) :"
		#grep ^Name "$FF_PROFILE_INI" | cut -f 2 -d=
		egrep '^(Name|Path)' "$FF_PROFILE_INI" | xargs -n 2 | tr -d '\r' | sed -e "s#Path=\\(.*\\)#$FF_PROFILE_DIR/\\1#" -e 's/ /\t - /'
		echo "Now launching the FF profile editor for you..."
		"${FF_EXE}" -P &
		return
		# Don't make a backup now
	fi

	RECENT_FF_BACKUPS=$(find $FF_PROFILE_DIR -maxdepth 1 -name 'ff-sessions*gz' -mmin -60)
	if [ -z "$RECENT_FF_BACKUPS" ]; then
		echo "No recent backups of FF sessions found."
		echo "While we're here, let's back up all FF profile sessions, just in case, stand by..."

	# And after losing yet another FF session due to the way it saves (or rather doesn't save) a recent
	# record of session files, I'm finally implementing something to stop that hopefully ever happening again.
	# $ cat sessionCheckpoints.json (after normal shutdown (session not set to restore))
	# {"profile-after-change":true,"final-ui-startup":true,"sessionstore-windows-restored":true,"quit-application-granted":true,"quit-application":true,"sessionstore-final-state-write-complete":true,"profile-change-net-teardown":true,"profile-change-teardown":true,"profile-before-change":true}
	# $ cat sessionCheckpoints.json (while running)
	# {"profile-after-change":true,"final-ui-startup":true,"sessionstore-windows-restored":true}
	#
	# Also, interestingly, an "empty" FF profile dir only contains this file:
	# $ cat test/times.json
	# {"created":1589449611997,"firstUse":1589449650455}


		tar vczf "$FF_PROFILE_DIR/ff-sessions-$(date +%Y%m%d-%H%M).tar.gz" \
			$FF_PROFILE_DIR/*/session* \
			$FF_PROFILE_DIR/*/*/session* \
		# So to restore an arbitrary session, one appears to need to copy "sessionstore.jsonlz4" back into
		# place from either the file with the same name, or from sessionstore-backup/recovery.jsonlz4, 
		# and modify sessionCheckpoints.json to the running version above. Then FF will start with
		# the button asking if you wish to restore your session, et voila, your session is reborn.
	else
		echo "Recent backups of FF sessions found :)"
		find $FF_PROFILE_DIR -maxdepth 1 -name 'ff-sessions*gz' -mmin -60
	fi

	# And now start FF, just in case the files get screwed up during startup
	for i in "$@"; do
		# Try to set FF sync device name and nightly tester title bar correctly:
		# Hmm nightly tester config is stored in sqlite. Bummer dude.
		PREFSJS="$(dirname $FF_PROFILE_INI)/$(egrep -iA 3 "^Name=${i}" "$FF_PROFILE_INI" | grep ^Path | cut -f 2 -d'=' | tr -d '\r\n')/prefs.js"
		ls -la "${PREFSJS}"*
		if [ -r "${PREFSJS}" ]; then
			echo "Updating FF sync debice name..."
			perl -pi.bak -e \
				"s/identity.fxaccounts.account.device.name\",.*\$/identity.fxaccounts.account.device.name\", \"${i} @ $HOSTNAME\");/" \
				"${PREFSJS}"
		fi
		ls -la "${PREFSJS}"*
		echo "Launching FireFox profile '$i'... "
		"${FF_EXE}" -P "$i" --new-instance &
	done
	
}

ffdp() {
	~/.local/share/umake/web/firefox-dev/firefox -P "$1" --new-instance &
}

xset-fast-keyboard() {
	delay_rate=$(xset q | grep 'repeat delay' | awk '{ print $4"/"$7 }')
	[ "$delay_rate" = "200/37" ] && return
	xset r rate 200 37
	echo -n "KB delay repeat rate: $delay_rate -> "
	xset q | grep 'repeat delay' | awk '{ print $4"/"$7 }'
}

git-convert-url() {
	if [ -z "$1" ]; then
		echo "Need argument 'ssh' or https' to convert your repo to"
	else
		case "$1" in
			ssh)
				echo before:
				git remote -v
				SSHURL=$(git remote -v | grep fetch | sed -e 's/.*:\/\///' -e 's/\//:/' | cut -f 1 -d' ')
				git remote set-url origin "git@${SSHURL}.git"
				echo after:
				git remote -v
				echo "Happy gitting! :)"
				;;
		esac
	fi
}

set-dhcp-lease-forever() {
	IF=$1
	ip addr show dev $IF
	echo "Setting interface $IF's IP to permanently valid"
	sudo ip addr change $(ip ad show dev $IF | grep -Po "(?<=inet )(\S+)") dev $IF valid_lft forever preferred_lft forever
	ip addr show dev $IF
}

### End of subroutines ###


### Part 5. Host specific stuff ###

if [ -f $HOME/.bashrc.local ]; then
	. $HOME/.bashrc.local
fi


if [ "$NOFUNCS" != 1 ]; then
	# Lets try the fancy shell out shall we, well, only if it's me
	if { echo $SUDO_USER $USER $USERNAME; ssh-add -l; } 2> /dev/null | egrep -qi "(erik|taal)"; then
		niceprompt
	fi
fi
