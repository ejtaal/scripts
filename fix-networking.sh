#!/bin/bash

# Detect where I am and set network accordingly

# TODO: rest of the script beyond this comment

timelimit -T 10 -t 5 tcpdump -qlni eth2 -c 5 -w /tmp/whereami.pcap arp 

if tcpdump -qln -r /tmp/whereami.pcap | grep 10.24.1.254; then
	PLACE='OFFICE'
fi
