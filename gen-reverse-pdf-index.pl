#!/usr/bin/perl
=pod

Usage: Run it like this:


Test command:

Based on:

=cut

# This script does need these libs installed please:
# apt-get install libstring-crc-cksum-perl libgeo-ip-perl
# If it's not in apt-cache or yum then do from the terminal:
# cpan> install String::CRC::Cksum
# cpan> install Geo::IP


use strict;
use warnings;

my $e="\e";

my $blackb=$e."[40m",   my $redb=$e."[41m",  my $greenb=$e."[42m";
my $yellowb=$e."[43m",  my $blueb=$e."[44m", my $purpleb=$e."[45m";
my $cyanb=$e."[46m",    my $whiteb=$e."[47m";

my $blackf=$e."[30m",   my $redf=$e."[31m",  my $greenf=$e."[32m";
my $yellowf=$e."[33m",  my $bluef=$e."[34m", my $purplef=$e."[35m";
my $cyanf=$e."[36m",    my $whitef=$e."[37m";

my $boldon=$e."[1m",    my $boldoff=$e."[22m";
my $italicson=$e."[3m", my $italicsoff=$e."[23m";
my $ulon=$e."[4m",      my $uloff=$e."[24m";
my $invon=$e."[7m",     my $invoff=$e."[27m";

my $reset=$e."[0m";


# Force line buffer flush
$| = 0;

my $tabs = "    ";
my $DEBUG = 0;
my $lasttop = 0, my $lastleft = 0;

while (<STDIN>) {
	chomp;
	if ( $DEBUG) {
		print "[".$_."]\n";
	}

	if ( m|^<text top="(\d+)" left="(\d+)".*?>(.*?)$| ) {
		my $top = $1;
		my $left = $2;
		my $text = $3;
		#print "Text detected, t: $top l: $left [$text]\n";
		if ( abs(
	}

	my $lasttop = $top;
	next;

#	#x m: 22:03:01.016311 IP 192.168.0.5.42565 > 194.168.4.100.53: UDP, length 70
#	#v m: 22:03:01.033744 IP 192.168.0.5.45625 > 194.168.4.100.53: UDP, length 59
#	# This regexp fails on perl startup, but then works afterwards??
#	if (m/^((?:[\d\-]+\s)?[\d:\.]+ )?([A-Z0-9]{2,}(?: \d+\.[\da-z]+(?=,))?)([ ,].*)/) {
#		my $timestamp = $1;
#		$protocol = $2;
#		$_ = "$3\n";
#
#		my $prefix = '';
#		if ( $last_line_was_hex == 1) { 
#			#print "last_line_was_hex $last_line_was_hex, printhex $printhex";
#			$last_line_was_hex = 0;
#			# New packet just arrived
#			if ( $printhex == 1) { $prefix = "$reset\n"; }
#			else { $prefix = "$reset"; }
#			$printhex = 0;
#			#print " NE".$reset."W:\n"; 
#		}
#
#		print $prefix.$whitef.$timestamp.$reset if $timestamp;
#		print cs_color( $protocol);
#		
#		if (m/tcp \d+/) { $ip_proto = 'tcp' }
#		elsif (m/ UDP/) { $ip_proto = 'udp' }
#		else { $ip_proto = '' } # not sure yet
#
#		# First shift things to the left before making it colourful
#		s/(Request who-has .*)(tell )($ipv4_addr)/arp_make_local_left( $1, $2, $3)/ge;
#		s/ (?<lip>$ipv4_addr)\.(?<lport>$port) > (?<rip>$ipv4_addr)\.(?<rport>$port)/" ".make_local_left( $+{lip}, $+{rip}, $+{lport}, $+{rport} )/ge;
#
#
#		# Numeric IPV6 address and port
#		#s/ $ipv6_addr\.\K$port(?=[ :,])?/\e[36m$&\e[0m/g;
#		#s/(?<!seq) \K$ipv6_addr(?=[ :,])?/\e[34m$&\e[0m/g;
#
#		# Numeric IPV4 address and port
#		#s/ ($ipv4_addr)\.($port)([ :,])?/print " ".cs_color($1).".".cs_color($2).$3/ge;
#
#		s/ ($ipv4_addr) > ($ipv4_addr)/" ".make_local_left( $1, $2)/ge;
#		s/ ($ipv4_addr)\.($port)([ :,]){1}/" ".cs_color($1).".".cs_color($2).$3/ge;
#		s/ ($ipv4_addr)([ ,:])/" ".cs_color($1).$2/ge;
#		
#		#s/^(0x[0-9a-fA-F]+0\s+[0-9a-fA-F\s]+) .*$/handle_hex($1)/e;
#		#s/ ($ipv4_addr)(\.$port) > ($ipv4_addr)(\.$port)([ :,])?/" ".fix_dir( $1, $2, $3, $4).$5/ge;
#		#s/ $ipv4_addr\.\K$port(?=[ :,])?/cs_color($&)/ge;
#		#s/(?<= )$ipv4_addr(?=[ :,])?/cs_color($&)/ge;
#
#		# FQDN
#		#s/ $fqdn\.\K$port(?=[ :,])?/\e[36m$&\e[0m/g;
#		#s/(?<= )$fqdn(?=[ :,])?/\e[34m$&\e[0m/g;
#
#		# Bridge
#		#s/(?<= )($port)\.($ipv4_addr|$ipv6_addr)\.($port)(?=[ :,])/\e[36m$1\e[0m.\e[34m$2\e[0m.\e[36m$3\e[0m/g;
#		#s/(?<= )($port)\.($ipv4_addr|$ipv6_addr)(?=[ :,])/\e[36m$1\e[0m.\e[34m$2\e[0m/g;
#
#
#		# Warnings
#		s/\[bad udp cksum[^\]]*\]/\e[31m$&\e[0m/;
#
#		# tcp/udp/icmp
#		s/( seq )(\d+):(\d+)/ $1.cs_color($2).":".cs_color($3)/ge;
#		s/( seq )(\d+),/ $1.cs_color($2)/ge;
#		s/(\], ack )(\d+)/ $1.cs_color($2-1, 1).$2.$reset/ge;
#		s/(([\d\s]|[\]],) ack )(\d+)/ $1.cs_color($2, 1).$2.$reset/ge;
#		# Need to study seq and ack more
#		#s/( seq )(\d+)/ $1.cs_color($2)/ge;
#		#s/( ack )(\d+)/ $1.cs_color($2-1)/ge;
#		s/( Flags )(\[S\])/$1$greenf$2$reset/;
#		s/( Flags )(\[S\.\])/$1$boldon$greenf$2$reset/;
#		s/( Flags )(\[R\.\])/$1$redf$2$reset/;
#		
#		s/ (ICMP)/ $boldon$bluef$1$reset/;
#		s/(udp port )(\d+)( unreachable)/"$redf$1$reset".cs_color($2)."$redf$3$reset"/e;
#		s/(unreachable)/$redf$1$reset/;
#		s/(echo request)/$greenf$1$reset/;
#		s/(echo reply)/$boldon$greenf$1$reset/;
#		
#		s/ (Request [\w-]+)/ $greenf$1$reset/;
#		s/ (Reply)/ $boldon$greenf$1$reset/;
#		
#		s/ (UDP)/ $boldon$greenf$1$reset/;
#		s/ (tcp \d+)/ $boldon$redf$1$reset/;
#		s/ (UDP)/ $boldon$greenf$1$reset/;
#		
#    if ( ! $last_line_was_hex ) { print };
#	
#  } else {
#		# Packet data (tcpdump -X)
#		#0x0030:  04c9 0534 3536 340d 0a41 6374 6976 6520  ...4564..Active.
#		if ( $ip_proto eq 'tcp' or $ip_proto eq 'udp') {
#			# TODO: add support for others?
#			s/^\s+(0x[0-9a-fA-F]+0:\s+[0-9a-fA-F\s]+) .*$/handle_hex($1)/e;
#		}
#	}
}
