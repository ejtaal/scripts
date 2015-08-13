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
fi

# User specific aliases and functions
umask 022

### Part 1. aliases ###
alias 2dos='perl -pi -e "s#([^\r]*?)\n#\$1\r\n#"'
# maybe better one?: perl -pi -e "s#([^\x0D]*?)\0A#\$1\0D\x0A#"
alias 2unix="perl -pi -e 's/\r//'"
alias agi="apt-get install"
alias ags='apt-get install $(apt-show-versions -u -b | grep security)'
alias acs="apt-cache search"
alias as="aptitude show"
alias bzless='{ bzcat | less; } <'
alias c='for ((i = 1; i < $LINES; i++)) do echo; done; clear'
alias cls='cd; for ((i = 1; i < $LINES; i++)) do echo; done; clear'
alias cp='cp -vip'
alias d='du -csk -- * .[^.]*'
alias ds='du -csk -- * .[^.]* | sort -n'
alias dh='du -csk -- * .[^.]* | sort -n | while read size fname; do for unit in k M G T P E Z Y; do if [ $size -lt 1024 ]; then echo -e "${size}${unit}\t${fname}"; break; fi; size=$((size/1024)); done; done'
alias ds='du -csk -- * .[^.]* | sort -n'
alias er="extract-rpm.sh"
alias ff="find . -name"
alias fixbackspace='reset -e "^?"'
alias fixbackspace2='stty erase `tput kbs`'
alias htmltidy='tidy -mi -wrap 100'
alias killdupes='fdupes -dr .'
alias ks="dcop `echo $KONSOLE_DCOP_SESSION | sed 's/.*(\(.*\),\(.*\).*)/\1 \2/'` setSize"
alias la='ls -alF'
alias ll='ls -lF'
alias l.='ls -dalF .[^.]*'
alias lt='ls -lartF'
alias lat='ls -latF'
alias mp3i='mp3info -x -ra -p "%-30F %6k kb  %02mm:%02ss  %.1r kbs  %q kHz  %o  mpg %.1v layer %L\n"'
alias mv='mv -vi'
alias onp='opera -newpage'
#alias psf='ps auxwww --forest | less -S'
alias psf='ps -eo user,pid,ni,%cpu,%mem,vsz,tty,stat,lstart,time,args --forest | less -S'
alias rm='rm -vi'
alias rpma='rpm -qa --qf "%{n}-%{v}-%{r}.%{arch}\n"'
alias rlsql='/usr/local/wmfs/scripts/rlsql.sh'
alias sagi="sudo apt-get install"
alias sf='start-firefox.sh'
alias smbmplayer='mplayer -cache 10000 -framedrop'
# This is getting more and more in the way:
#alias su='su -m'
alias svnid='svn propset svn:keywords Id'
alias svnex='svn propset svn:executable 1'
alias svkid='svk propset svn:keywords Id'
alias svkex='svk propset svn:executable 1'
alias svnign='svn propset svn:ignore'
alias spaces2underscores='for a in *\ *; do mv -vi "$a" ${a// /_}; done'
alias supernice='ionice -c 3 nice'
alias vanish="kill -9 $$"
alias vimhtml='vim -c ":se ft=html"'
alias vimphp='vim -c ":se ft=php"'
alias watp='watch --differences=permanent -n'
alias watc='watch --differences=cumulative -n'
alias x='startx'
alias xset-fast-keyboard='xset r rate 200 36'

# konsole_title aliases
alias bt='konsole_title bt'
alias btupload='konsole_title bt --minport 6901 --maxport 6910 --max_upload_rate 20'
alias emerge='konsole_title emerge'
alias esniper='konsole_title esniper'
alias finch='konsole_title finch'
alias htop='konsole_title htop'
alias irssi='konsole_title irssi'
alias less='konsole_title less'
alias links='konsole_title links'
alias make='konsole_title make'
alias man='konsole_title man'
alias mc='konsole_title mc'
alias mplayer='konsole_title mplayer'
alias msfconsole='konsole_title msfconsole'
alias mutt='konsole_title mutt'
alias ncdu='konsole_title ncdu'
alias ping='konsole_title ping'
alias psql='konsole_title psql'
alias rtorrent='konsole_title rtorrent'
alias scp='konsole_title scp'
alias screen='konsole_title screen'
alias snownews='konsole_title snownews'
alias sqlplus='konsole_title sqlplus'
alias ssh='konsole_title ssh'
alias sudo='konsole_title sudo'
alias tail='konsole_title tail'
alias multitail='konsole_title multitail'
alias telnet='konsole_title telnet'
alias vim='konsole_title vim'
alias wget='konsole_title wget'

# Please no ugly colours from ls:
alias ls > /dev/null 2>&1 && unalias ls
### End of aliases ###

### Part 2. Variables ###

# Dynamically build path:
ADDPATH="/sbin:/usr/sbin:/usr/local/sbin:/usr/X11R6/bin:/usr/local/bin:$HOME/bin:$HOME/scripts"
#if [ -d "${HOME}/scripts/" ]; then
#  for dir in `find "${HOME}/scripts/" -type d -regex "[^.]*"`; do
#    ADDPATH="${ADDPATH}:$dir"
#  done
#fi

export PATH="$PATH:${ADDPATH}"
export AGENTFILE="/home/taal/.ssh/agent.rc"
export EDITOR="vim"
export PAGER="less"
export PS1='\u@\h:\w> '
#export TERM="linux"
unset LS_COLORS
#export HISTCONTROL="ignoredups:"
export HISTFILESIZE=50000
export HISTSIZE=50000
export HISTTIMEFORMAT="%Y-%m-%d--%H:%M"
export SVKDIFF="/usr/bin/diff -u"
export STATUSLINE_DELAY=10
export USERNAME=$(whoami)
export SUDO_EDITOR='rvim'

shopt -s histappend
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
	

### End of variables ###

### Part 3. Subroutines ###

cu() { date '+cu start: %H:%M:%S %d-%b-%Y' && cvs -q update $@ | sed -e 's/^[UP]/[1;37;42m&[0m/' -e 's/^\?/[1;37;41m&[0m/' -e 's/^C/[1;37;45m&[0m/' -e 's/^[RMA]/[1;37;44m&[0m/'; date '+cu end:   %H:%M:%S %d-%b-%Y'; }

normalprompt() {
	export PROMPT_COMMAND=""
	export PS1='\u@\h:\w> '
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
	
	[ -z "$BASH_COMMAND_START" ] && export BASH_COMMAND_START=$(date +"%s%3N")
}

preexec_invoke_exec () {
    [ -n "$COMP_LINE" ] && return  # do nothing if completing
    local this_command=`history 1 | sed -e "s/^[ ]*[0-9]*[ ]*//g"`;
    preexec "$this_command"
		
}
trap 'preexec_invoke_exec' DEBUG

prompt_command() {
  # First get the last exit code to display later
  LASTEXIT=$?

	indentcolour="$boldon$cyanf"
  if [ $USERNAME = "root" -o "$UID" = 0 ]; then
		usercolour="$boldon$redf"
		indentcolour="$boldon$redf"
		prompt_char='#'
  else
		usercolour="$boldon$greenf"
		prompt_char='$'
  fi;
	PS1="\[${indentcolour}\]${prompt_char}\[${reset}\] "
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
  if [ -n "$SSH_CLIENT" -o -n "$KONSOLE_DCOP" -o "$TERM" = "xterm" -o "$TERM" = "xterm-color" ]; then
    # Set konsole window title
    echo -n -e "\e]0;$(whoami) @ $HOSTNAME | $PROMPTDIR   | \a";
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
	batno=0
	for i in /sys/class/power_supply/BAT*; do
		if [ ! -f "$i" ]; then
			continue
		fi
		batno=$((batno+1))
		bat=$(basename $i)
		#full=$(cat $i/charge_full)
		#now=$(cat $i/charge_now)
		#model=$(cat $i/model_name)
		#tech=$(cat $i/technology)
		current=$(cat $i/current_now)
		status=$(cat $i/status)
		#perc=$((current*100/full))
		cap=$(cat $i/capacity)
		if [ "$status" = 'Discharging' ]; then
			bat_color="${yellowf}"
			if [ "${cap}" -le 20 ]; then
				bat_color="${redf}"
			fi
		else
			bat_color="${greenf}"
		fi
		if [ "$batno" = '1' ]; then
			echo -n ' | '
			line2="${line2} | "
		fi
		echo -ne "${boldon}${bat_color}${cap}%${reset} "
		line2="${line2} ${cap}%"
	done
	line2="${line2}${uptime_etc}"
	CURPOS=${#line2}

	SPACELEFT=$((COLUMNS-CURPOS))
	i=1
	while [ $i -lt $SPACELEFT ]; do
		i=$((i+1))
		echo -ne " "
	done
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
	XINFO=""
	if [ -n "$DISPLAY" ]; then
		MOREINFO="$MOREINFO X"
		XINFO=" $boldon${yellowf}X$reset"
	fi
	#echo MARK
	#echo MOREINFO = $MOREINFO
	MOREINFOLENGTH=${#MOREINFO}
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
# Now launch the statusline in the background
	#statusline &
	#write_statusline "[...gathering system information...]"
	#dist_info=$(get_basic_dist_info)
	get_basic_dist_info

	tty=$(tty | sed -e 's#^/dev/##')
	COLUMNS=${COLUMNS:-80}
  HOSTNAME=$(echo ${HOSTNAME%%\.*} | tr A-Z a-z)
  HOST_COLOR="${yellowf}"
	if [ -n "$VM_TYPE" ]; then
  	HOST_COLOR="${cyanf}"
	fi

	INSIDE_SCREEN=n
  if echo "$TERMCAP" | grep -q 'screen'; then
		INSIDE_SCREEN=y
	fi
	
	export PROMPT_COMMAND="prompt_command"
	export PS1="> "
	export PS2='...> '
}

konsole_title() {
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
			ssh-add "$key" 2> /dev/null
		fi
	done
}

find_ssh_agent() {
	# Check for any available ssh-agents that contains keys:
	for agent in /tmp/ssh-*/agent.*; do
		export SSH_AUTH_SOCK=$agent
		ssh-add -l | grep -q " [0-9][0-9]:" && break
		SSH_AUTH_SOCK=
	done
	# If no suitable agent was found then run the ssh-agent 
	# and add my ssh-key(s), but only if we're on a tty (to
	# stop this popping up before logging in to KDE
	if tty > /dev/null 2>&1; then
		if [ -z "$SSH_AUTH_SOCK" -a -d "$HOME/.ssh/" ]; then
			eval $(ssh-agent) > /dev/null
			unset SSH_ASKPASS
			loadsshkeys
		fi
	fi
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

	MINPLUS=$(diff -u ${R} "$1" "$2" | grep "^[-+]" | grep -v "^---\|^+++" | cut -b 1 | sort | uniq -c | xargs echo)
	echo "# $MINPLUS" > "$TMPDIFF"
	diff -u ${R} "$1" "$2" >> "$TMPDIFF"
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
		plex)
			$WAKE 10.0.2.255 00:06:5b:70:d2:66
			;;
		berry)
			$WAKE 10.0.2.255 00:14:C2:D7:DB:6A
			;;
		bluenova)
			$WAKE 10.0.2.255 00:1e:8c:e6:2f:48
			;;
		wombat)
			$WAKE 10.32.48.255 00:08:02:BD:EA:19
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
	if [ $mins -gt 0 ]; then final="${final}${mins}m"; msecs=; fi
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

### End of subroutines ###

# Set up ssh keys if present
find_ssh_agent

### Part 5. Host specific stuff ###

if [ -f $HOME/.bashrc.local ]; then
	. $HOME/.bashrc.local
fi

# Lets try the fancy shell out shall we
niceprompt
