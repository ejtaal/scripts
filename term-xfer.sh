#!/bin/bash
#
# term-xfer.sh — Foolproof encrypted file transfer via stdout
#
# Encrypt a file and output base64 for safe copy-paste.
# Decrypt base64 input from stdin back to a file.

set -euo pipefail

T=$(basename "$0")
usage() {
  cat <<EOF
Usage:
  $T generate                     # show a new ENCKEY
  ENCKEY='myphrase' $T encrypt file.tar.bz2
    → prints base64 text to stdout
  echo "base64 text here" | ENCKEY='myphrase' $T decrypt -o output.tar.bz2
    → writes decrypted file
EOF
}

# --- Config ---
CIPHER="aes-256-cbc"

# Ambiguous-safe alphabet: no O/0, l/1, I, U/u
CHARS="abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789"

# Generate a 10-char pronounceable key from /dev/urandom
# Format: 5 chars - 5 chars (hyphen for readability)
generate_key() {
  local key=""
  local i
  for (( i=0; i<10; i++ )); do
    if (( i == 5 )); then key+="-"; fi
    local idx
    idx=$(od -An -tu1 -N1 /dev/urandom | tr -d ' ')
    local cidx=$(( idx % ${#CHARS} ))
    key+="${CHARS:$cidx:1}"
  done
  echo "$key"
}

# --- Encrypt + encode (file → stdout) ---
do_encrypt() {
    local infile="$1"
    [ -f "$infile" ] || { echo "Error: $infile not found" >&2; exit 1; }
    : "${ENCKEY:=$(generate_key)}"  # auto-generate if not set
    echo "ENCKEY=$ENCKEY"
    openssl enc -"$CIPHER" -salt -pbkdf2 -iter 100000 \
        -pass pass:"$ENCKEY" \
        -in "$infile" | base64 | fmt -w 76 | sed '/^$/d'
}

# --- Decrypt + decode (stdin → file) ---
do_decrypt() {
    local outfile=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o|--out) outfile="$2"; shift 2 ;;
            *) break ;;
        esac
    done
    [ -z "$outfile" ] && outfile="decrypted_output"

    base64 -d 2>/dev/null | sed '/^$/d' | \
        openssl enc -d -"$CIPHER" -salt -pbkdf2 -iter 100000 \
        -pass pass:"$ENCKEY" \
        -out "$outfile"
}

# --- Dispatch ---
case "${1:-help}" in
    gen|generate)
        echo "ENCKEY=$(generate_key)"
        ;;
    encrypt|enc)
        do_encrypt "${2:?$T: usage: $T encrypt <file>}"
        ;;
    decrypt|dec)
        shift; do_decrypt "$@"
        ;;
    help|--help)
        usage
        ;;
    *)
        echo "Unknown command: $1" >&2
        echo "$0: unknown command: $1" >&2
        usage >&2
        exit 1
        ;;
esac
