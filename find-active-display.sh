#!/bin/bash
#
# find-active-display.sh — Find the most recently active SSH session
# and output its DISPLAY / SSH_AUTH_SOCK configuration.
#
# Usage:
#   ./find-active-display.sh          # current user
#   ./find-active-display.sh username # specific user
#
# Outputs (one per line, ready to eval):
#   DISPLAY=:10.0
#   PID=1234
#   SESSION=pts/2
#   IDLE=1
#
# Exit 0 = X session found, exit 1 = none found.
#

set -euo pipefail
TARGET_USER="${1:-$USER}"

# Read env from /proc/PID/environ (null-separated)
# Usage: get_env_var $PID DISPLAY
get_env_var() {
  local pid="$1" var="$2"
  if [ -r "/proc/$pid/environ" ]; then
    tr '\0' '\n' < "/proc/$pid/environ" | grep "^${var}=" | head -1 | cut -d= -f2-
  fi
}

# 1. Get all sessions for the user with their PIDs and idle time
#    ps format: PID TTY TIME COMMAND
#    w format: USER TTY FROM LOGIN@ IDLE WHAT
# We combine both: get sessions from 'w', then look up PID from ps

declare -A session_idle
declare -A session_pid

# Get idle times from w
while IFS= read -r line; do
  tty=$(echo "$line" | awk '{print $2}')
  idle_raw=$(echo "$line" | awk '{print $5}')
  
  # Convert idle to seconds for sorting
  if [ "$idle_raw" = "?" ]; then
    idle=999999
  elif [[ "$idle_raw" =~ ^([0-9]+):([0-9]+)m$ ]]; then
    # M:SSm or H:MMm format — treat first part as hours if >59, else minutes
    first=${BASH_REMATCH[1]}
    second=${BASH_REMATCH[2]}
    if [ "$first" -gt 59 ]; then
      idle=$(( 10#$first * 3600 + 10#$second * 60 ))
    else
      idle=$(( 10#$first * 60 + 10#$second ))
    fi
  elif [[ "$idle_raw" =~ ^([0-9]+):([0-9]+)$ ]]; then
    # H:MM or M:SS format — treat first part as hours if >59, else minutes
    first=${BASH_REMATCH[1]}
    second=${BASH_REMATCH[2]}
    if [ "$first" -gt 59 ]; then
      idle=$(( 10#$first * 3600 + 10#$second * 60 ))
    else
      idle=$(( 10#$first * 60 + 10#$second ))
    fi
  elif [[ "$idle_raw" =~ ^([0-9]+\.?[0-9]*)m$ ]]; then
    idle=$(awk "BEGIN {printf \"%d\", ${BASH_REMATCH[1]} * 60}")
  elif [[ "$idle_raw" =~ ^([0-9]+\.?[0-9]*)h$ ]]; then
    idle=$(awk "BEGIN {printf \"%d\", ${BASH_REMATCH[1]} * 3600}")
  elif [[ "$idle_raw" =~ ^([0-9]+\.?[0-9]*)d$ ]]; then
    idle=$(awk "BEGIN {printf \"%d\", ${BASH_REMATCH[1]} * 86400}")
  elif [[ "$idle_raw" =~ ^([0-9]+\.?[0-9]*)s$ ]]; then
    idle=$(awk "BEGIN {printf \"%d\", ${BASH_REMATCH[1]}}")
  else
    # Fallback: strip any suffix, treat as seconds
    idle=$(echo "$idle_raw" | grep -oE '^[0-9]+\.?[0-9]*' | awk '{printf "%d", $1 + 0}')
    idle=${idle:-0}
  fi
  
  session_idle["$tty"]=$idle
  
  # Get PID for this tty (login shell or most recent)
  pid=$(ps -t "$tty" -o pid= --sort=-etime 2>/dev/null | head -1 | xargs)
  if [ -n "$pid" ]; then
    session_pid["$tty"]=$pid
  fi
done < <(w -h "$TARGET_USER" 2>/dev/null | grep -E '(pts/|:[0-9])' || true)

# 2. Sort sessions by idle time (ascending = least idle first)
if [ ${#session_idle[@]} -eq 0 ]; then
  echo "DISPLAY=:"
  echo "No active sessions for $TARGET_USER"
  exit 1
fi

sorted_tty=$(for tty in "${!session_idle[@]}"; do
  echo "${session_idle[$tty]} $tty"
done | sort -n | awk '{print $2}')

# 3. Walk sessions from least-idle to most, looking for DISPLAY
best_display=""
best_auth_sock=""
best_pid=""
best_session=""
best_idle=""

for tty in $sorted_tty; do
  pid="${session_pid[$tty]:-}"
  [ -z "$pid" ] && continue
  
  display=$(get_env_var "$pid" DISPLAY)
  
  # Accept if it looks like an X display: :N, :N.M, or host:N.M
  # Skip bare ':' or wayland unix sockets
  if [[ -n "$display" && ! "$display" = ":" && ! "$display" =~ ^unix && ( "$display" =~ ^[a-zA-Z0-9._-]+:[0-9] || "$display" =~ ^:[0-9] ) ]]; then
    echo "DISPLAY=$display"
    echo "PID=$pid"
    echo "SESSION=$tty"
    echo "IDLE=${session_idle[$tty]}"
    exit 0
  fi
done

# 4. No X session found
echo "DISPLAY=:"
echo "No X session found for $TARGET_USER"
exit 1
