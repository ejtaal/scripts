#!/bin/bash

# One could use this for any program that outputs data on stdout, to prefix it with
# a timestamp, like so:
#	$ for a in {1..9999}; do echo a = $a ':)'; sleep 0.5; done | prefix-timestamps.sh

cat | perl -MPOSIX -p -e 's/^/strftime "[%F %T] ", localtime /e'
