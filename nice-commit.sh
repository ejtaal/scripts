#!/bin/bash
#
# This script allows you to type your source control commit
# message in one of two vim windows, while you can see the 
# diff of your work in the window below.
#
# License: BSD
# Copyright: (c) 2006-2014 Erik Taal <ejtaal@gmail.com>
#

TMPDIFF="/tmp/cvs-$USER-diff.$$"
ERRORS=0
for file in "$@"; do
  file "$file" | grep 'shell script text' && { sh -n "$file" || ERRORS=1; }
  file "$file" | grep 'perl script text'  && { perl -wc "$file" || ERRORS=1; }
  [ -x /usr/bin/tidy ] && file "$file" | \
    grep 'ML document text'  && { /usr/bin/tidy -e "$file" || ERRORS=1; }
  grep -q '^<?$' "$file" && { php -l "$file" || ERRORS=1; }
done

if [ $ERRORS -eq 0 ]; then
  echo "Syntax OK"
  sleep 2
else
  echo "Syntax errors, see above"
  exit 1
fi

VIMHACK=/tmp/vim-swapwindows.sh
if [ -d "`dirname "$1"`/CVS" ]; then
  DIFFCMD="cvs diff"
  COMMITCMD="cvs commit"
  CVSEDITOR="${VIMHACK} $TMPDIFF"
elif [ -d "`dirname "$1"`/.svn" ]; then
  DIFFCMD="svn diff"
  COMMITCMD="svn commit"
  EDITOR="${VIMHACK} $TMPDIFF"
elif [ -d "$HOME/.svk" ]; then
  DIFFCMD="svk diff"
  COMMITCMD="svk commit"
  EDITOR="${VIMHACK} $TMPDIFF"
elif [ -f "$HOME/.gitconfig" ]; then
  DIFFCMD="git diff"
  COMMITCMD="git commit -a"
  EDITOR="${VIMHACK} $TMPDIFF"
fi

echo "# $MINPLUS" > "$TMPDIFF"
$DIFFCMD "$@" > "$TMPDIFF.tmp"
MINPLUS=$(grep "^[-+]" "$TMPDIFF.tmp" | grep -v "^---\|^+++" | cut -b 1 | sort | uniq -c | xargs echo)
cat "$TMPDIFF.tmp" >> "$TMPDIFF"

MINPLUS=$($DIFFCMD "$@" | grep "^[-+]" | grep -v "^---\|^+++" | cut -b 1 | sort | uniq -c | xargs echo)
echo '# vim:ft=diff:syntax=diff' >> "$TMPDIFF"

echo '#!/bin/sh' > "${VIMHACK}"
LINES=$(tput lines)
third=$((LINES/3))
echo "vim -c 'resize $third' -o \"\$2\" \"\$1\"" > "${VIMHACK}"
chmod +x "${VIMHACK}"

$COMMITCMD "$@"
#rm -f $TMPDIFF

# vim:ft=sh:
