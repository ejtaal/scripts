#!/bin/bash

if [ -f ~/scripts/generic-linux-funcs.sh ]; then
  . ~/scripts/generic-linux-funcs.sh
else
  echo generic-linux-funcs.sh not found :-/
  NOFUNCS=1
	exit 1
fi

# Semi intelijent firejail wrapper
# Three use cases? venv, appimage, or custom cmd

# TODO" set --name also




if [ ! -x /usr/bin/firejail ]; then
	hm '!' "No firejail exe found"
	return 1
fi

if [ -z "$1" ]; then
	# Show usage and list current jails
	echo "Usage: fj 'venv' VENV_NAME | EXECUTABLE | APP_IMAGE_FILE"

	echo "Usage: fj base-profile modification wl WHITELIST_DIR_FILE ro READONLY_DIR_FILE"
	firejail --list \
		| while read line; do
			hm \* $line
			pid="${line%%:*}"
#				firejail --apparmor.print=$pid
#				firejail --caps.print=$pid
#				firejail --cpu.print=$pid
#				firejail --dns.print=$pid
#				firejail --fs.print=$pid
#				firejail --net.print=$pid
#				firejail --netfilter.print=$pid
#				firejail --netfilter6.print=$pid
				hm + "Profile: $(firejail --profile.print=$pid)"
#				firejail --protocol.print=$pid
#				firejail --seccomp.print=$pid
			pstree -Tap "$pid"

		done
	hm \* 'Available local FJ profiles:'
	ls -1 ~/.config/firejail/ | sed 's/.local$//' | xargs
	exit 1
fi


FJ_OPTIONS=
LOCAL_PROFILE=
VENV_ENABLED=n
APP_IMAGE_ENABLED=n
APP_IMAGE_FILE=
# Have a default name for a FJ profile
LOCAL_PROFILE_NAME=default
NET_ENABLED=none
for option in "$@"; do
	echo parsing option "$option"

	if ip addr show dev "$option" 2> /dev/null 1>&2; then
		echo "Network device $option received, running firejail with --net=$option"
		NET_ENABLED="$option"
	elif [ "$option" = "venv" ]; then
		VENV_ENABLED=y
	# if App image
	elif [ -f "$option" ]; then
		file="$option"
		if xxd -s 8 -l 3 "$file" | grep -q '4149 02'; then
			hm + Appimage detected
			APP_IMAGE_ENABLED=y
			APP_IMAGE_FILE="$file"
		else
			#if [ -x "$option" ]; then
			# regular target file or option thereof
			FJ_OPTIONS="$FJ_OPTIONS $option"
		fi
### 	elif [ -z "$FJ_OPTIONS" ]; then
### 		LOCAL_PROFILE_NAME="$option"
	else
		# We've been given a random command or its argument, so append verbatim
		if [ "$option" = 'vscodium' ]; then
			hm \* "Special case $option detected"
			APP_IMAGE_ENABLED=y
			APP_IMAGE_FILE="$(ls -t1 ~/Downloads/VSCodium-*-x86_64.AppImage | tail -1)"

			FJ_OPTIONS="$FJ_OPTIONS "
		elif [ "$option" = 'scripts' ]; then
			hm \* "Special case $option detected"

			FJ_OPTIONS="$FJ_OPTIONS
				--whitelist=~/scripts
				--whitelist=~/.config/VSCodium
				"

			FJ_POSTARGS=/home/taal/scripts/scripts.code-workspace
		else
			FJ_OPTIONS="$FJ_OPTIONS $option"
		fi
	fi

#				# validate it first
#				#firejail --profile="$FJ_PROFILE" --appimage ~/Downloads/validate-i686.AppImage ~/Downloads/validate-i686.AppImage
#				firejail --appimage ~/Downloads/validate-i686.AppImage --help
#				firejail --appimage ~/Downloads/validate-i686.AppImage --appimage-signature
#				firejail --profile="$FJ_PROFILE" --appimage ~/Downloads/validate-i686.AppImage --appimage-signature
#				#firejail --appimage "$APP_IMAGE"
			
done
	
FJ_OPTIONS="$FJ_OPTIONS --net=$NET_ENABLED"

if [ "$VENV_ENABLED" = y ]; then
	venv_name="$LOCAL_PROFILE_NAME"
	venv_dir="$HOME/venvs/$venv_name"
	if [ -d "$venv_dir" ]; then
		hm \* "Initializing firejail for python venv $venv_name ($venv_dir) ..."
	else
		hm \! "venv $venv_name ($venv_dir) not found!"
		return 1
	fi

	FJ_PROFILE="$HOME/.config/firejail/python-venv-${venv_name}.local"
	if [ -f "$FJ_PROFILE" ]; then
		echo "Using existing config in $FJ_PROFILE ..."
	else
		echo Initializing firejail config in $FJ_PROFILE ...
		#BLACKLIST_DIRS="$(find ~/.mozilla/firefox/ -mindepth 1 -maxdepth 1 -type d | perl -pe 's/^/blacklist /;' | grep -v "/$i$")"
		echo "

# Include baseline Firefox sandboxing
#include /etc/firejail/firefox.profile

# Blacklist all profile dirs except requested profile 
whitelist $venv_dir
whitelist $HOME/scripts
read-only $HOME/scripts

# Optional: isolate cache and temp
private-cache
private-tmp

# Drop dangerous privileges
caps.drop all
seccomp
nonewprivs
" 			> "$FJ_PROFILE"
	fi
		#FJ_OPTIONS="$FJ_OPTIONS --profile='$FJ_PROFILE'"
		
	echo "
. $HOME/scripts/shellrc
venv $venv_name
" 		> $venv_dir/bash-init.sh

	#echo -- firejail --profile="$FJ_PROFILE" bash --rcfile $venv_dir/bash-init.sh  -i
	FJ_OPTIONS="$FJ_OPTIONS --profile='$FJ_PROFILE' bash --rcfile $venv_dir/bash-init.sh  -i"
	# End of venv option
elif [ "$APP_IMAGE_ENABLED" = y ]; then
	appname="${APP_IMAGE_FILE%%-*}"
	appname="${appname##*/}"

### 	if [ -n "$LOCAL_PROFILE_NAME" ]; then
### 		FJ_PROFILE="$HOME/.config/firejail/appimage-${LOCAL_PROFILE_NAME}-${appname}.local"
### 	else
### 		FJ_PROFILE="$HOME/.config/firejail/appimage-${appname}.local"
### 	fi
### 
### 	if [ -f "$FJ_PROFILE" ]; then
### 		echo "Using existing config in $FJ_PROFILE ..."
### 	else
### 		echo Initializing firejail config in $FJ_PROFILE ...
### 		#BLACKLIST_DIRS="$(find ~/.mozilla/firefox/ -mindepth 1 -maxdepth 1 -type d | perl -pe 's/^/blacklist /;' | grep -v "/$i$")"
### 		echo "
### # Include baseline Firefox sandboxing
### #include /etc/firejail/firefox.profile
### 
### # Blacklist all profile dirs except requested profile 
### #whitelist $venv_dir
### #whitelist $HOME/scripts
### #read-only $HOME/scripts
### 
### # Optional: isolate cache and temp
### private-cache
### private-tmp
### 
### # Drop dangerous privileges
### caps.drop all
### seccomp
### nonewprivs
### 
### #whitelist YOUR_DIR
### #read-only YOUR_DIR
### " 			> "$FJ_PROFILE"
### 	fi
	
	# Specify --appimage first so that ?HAS_APPIMAGE in profiles works
	FJ_OPTIONS="$FJ_OPTIONS --appimage $APP_IMAGE_FILE $FJ_POSTARGS"
	hm \* Running firejail as: "firejail $FJ_OPTIONS"
	firejail $FJ_OPTIONS
else
	# Just some other random command?
	hm \* Running firejail as: "firejail $FJ_OPTIONS"
	#firejail $FJ_OPTIONS
	
fi


#:||{
#			
#				#cat $HOME/scripts/shellrc > $venv_dir/bash-init.sh
#				echo "
#. $HOME/scripts/shellrc
#venv $venv_name
#" 			> $venv_dir/bash-init.sh
#
#				echo -- firejail --profile="$FJ_PROFILE" bash --rcfile $venv_dir/bash-init.sh  -i
#				#firejail --profile="$FJ_PROFILE" bash --rcfile $venv_dir/bash-init.sh  -i
#}

