#!/bin/bash

reset
date

VPNINFO=/tmp/wmfsvpn.ifconfig.txt
echo -n "[*] Latest wmfsvpn message is from: "
date -r "$VPNINFO"

WMFSVPN_IP=$(cat $VPNINFO | grep -m 1 '172\.' | sed 's/.*inet addr:\(.*\) B.*/\1/')
echo "[*] WMFSVPN reported its ip as: $WMFSVPN_IP"

#ssh -v \
ssh -t -XYC \
	-o 'ConnectTimeout 10' \
	-o 'BatchMode yes' \
	-o 'ServerAliveInterval 30' \
	-o 'StrictHostKeyChecking no' \
	-o 'VisualHostKey yes' \
	-o 'UserKnownHostsFile ~/.ssh/reverse-vpn_known_hosts' \
	-L 2022:10.0.5.1:22 \
	-L 2023:192.168.0.40:22 \
	-L 5910:10.0.5.1:5900 \
	-L 5921:192.168.0.204:5901 \
	-L 5922:192.168.0.20:5902 \
	-L 5923:192.168.0.20:5903 \
	-L 5924:192.168.0.20:5904 \
	-L 5925:192.168.0.20:5905 \
	-L 8888:127.0.0.1:8888 \
	-L 8889:10.0.5.5:8888 \
	taal@$WMFSVPN_IP "$@"
