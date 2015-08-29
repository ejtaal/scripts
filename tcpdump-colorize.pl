#!/usr/bin/perl


=pod
tcpdump-colorize 2.0

Colorize ip and port number consistently, so it's easier for humans to track
who is talking to who (plus it looks really cool! :) )
Erik Taal <ejtaal@gmail.com>

Based on:
tcpdump-colorize 1.0
Nicolas Martyanoff <khaelin@gmail.com>
This script is in the public domain.
=cut

# This script does need these libs installed please:
# apt-get install libstring-crc-cksum-perl libgeo-ip-perl
# If it's not in apt-cache or yum then do from the terminal:
# cpan> install String::CRC::Cksum
# cpan> install Geo::IP
use String::CRC::Cksum qw(cksum);
use Geo::IP;
my $gi = Geo::IP->new(GEOIP_MEMORY_CACHE);

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

my @nice_colors = (
$blueb.$redf,
$blueb.$greenf,
$blueb.$yellowf,
$blueb.$purplef,
$blueb.$cyanf,
$blueb.$whitef,
$blueb.$boldon.$redf,
$blueb.$boldon.$greenf,
$blueb.$boldon.$yellowf,
$blueb.$boldon.$bluef,
$blueb.$boldon.$purplef,
$blueb.$boldon.$cyanf,
$blueb.$boldon.$whitef,

$whiteb.$redf,
$whiteb.$yellowf,
$whiteb.$purplef,
#$whiteb.$boldon.$redf,
#$whiteb.$boldon.$yellowf,
#$whiteb.$boldon.$bluef,

$yellowb.$redf,
$yellowb.$bluef,
$yellowb.$purplef,
$yellowb.$cyanf,
$yellowb.$whitef,
$yellowb.$boldon.$yellowf,
$yellowb.$boldon.$whitef,

$redb.$greenf,
$redb.$cyanf,
$redb.$whitef,
$redb.$boldon.$redf,
$redb.$boldon.$greenf,
$redb.$boldon.$yellowf,
$redb.$boldon.$bluef,
$redb.$boldon.$purplef,
$redb.$boldon.$cyanf,
$redb.$boldon.$whitef,

$blackb.$redf,
$blackb.$greenf,
$blackb.$yellowf,
$blackb.$bluef,
$blackb.$purplef,
$blackb.$cyanf,
$blackb.$whitef,
$blackb.$boldon.$redf,
$blackb.$boldon.$greenf,
$blackb.$boldon.$yellowf,
$blackb.$boldon.$bluef,
$blackb.$boldon.$purplef,
$blackb.$boldon.$cyanf,
$blackb.$boldon.$whitef,
);
my $no_colors = scalar @nice_colors;

#print "Size: ",scalar @nice_colors,"\n";

foreach $a ( @nice_colors) {
	#print "value of a: $a"."Test string$reset\n";
}

my @test_strings = (
"10.0.0.1",
"66.36.3.1",
"77.27.2.1",
"88.18.1.1",
"11.81.8.1",
"122.72.7.1",
"133.63.6.1",
"144.54.5.1",
"155.45.4.1",
"166.36.3.1",
"177.27.2.1",
"188.18.1.1",
"10.18.0.119",
"10.18.0.118",
"10.18.0.116",
"10.18.0.119",
"172.168.0.17",
"172.168.0.16",
"172.168.0.19",
"172.168.0.18",
"172.168.0.16",
"172.168.0.19",
"172.168.0.17",
"10.168.0.119",
"10.168.0.118",
"10.168.0.116",
"10.168.0.119",
"172.168.0.117",
"172.168.0.116",
"172.168.0.119",
"172.168.0.118",
"172.168.0.116",
"172.168.0.119",
"172.168.0.117",
"192.168.0.116",
"192.168.0.119",
"192.168.0.118",
"192.168.0.116",
"192.168.0.119",
"192.168.0.117",
"192.168.0.116",
"192.168.0.117"
);

#use String::CRC;
#use Digest::MD5 qw(md5_hex);

foreach $a ( @test_strings) {
	my $country = $gi->country_code_by_addr( $a);
	if ( ! $country) { $country = "__"; }
	#print cs_color($a)."(".cs_color($country).")\n";
#	#my $checksum = crc( $a, 32) % $no_colors;
#	my $checksum = cksum( $a) % $no_colors;
#	#print "value of a: $a".", crc: $crc_small\n";
#	#my $checksum = unpack("%32W*", $a) % $no_colors;
#	#my $checksum = unpack("%64A*", $a) % $no_colors;
#	print "value of a: $a".", crc: $checksum, therefore: ".$nice_colors[$checksum].$a.$reset."\n";
}

#exit 99;

# Assign a colour to a string depending on its CRC
sub cs_color {
	my $s = shift;
	my $color_only = shift;
	my $cs = cksum( $s) % $no_colors;
	#print "value of s: [$s]".", crc: $cs, therefore: [".$nice_colors[$cs].$s.$reset."]\n";
	if ( $color_only) { return $nice_colors[$cs]; }
	else { return $nice_colors[$cs].$s.$reset; }
	#return $boldon.$redf.$s.$reset;
}

# Assign left to RFC1918 adds?


my $hex = qr/[0-9a-f]/;
my $fqdn = qr/(?:[A-Za-z\d\-\.]+\.[a-z]+)/;
#my $ipv4_addr = qr/(?:(?:\d{1,3}\.){3}\d{1,3})/;
my $ipv4_addr = qr/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/;
my $ipv6_grp = qr/$hex{1,4}/;
my $ipv6_addr = qr/(?:::)?(?:${ipv6_grp}::?)+${ipv6_grp}(?:::)?/;
my $ipv6_rev = qr/(?:(?:$hex\.){31}$hex)/;
   $ipv6_addr = qr/(?:$ipv6_addr|$ipv6_rev)/;
my $port = qr/(?:\d{1,5}|[a-z\d\-\.]+)/;

#my $rfc = qr/(?:\d{1,5}|[a-z\d\-\.]+)/;

# This reads in all our own inet4/6 and MAC addresses, to be used in make_local_left()
my @own_addresses = `ip addr | egrep "(inet|ether)" | sed -e 's/\\/[0-9].*//' | awk '{ print \$2 }'`;
chomp @own_addresses;
print $boldon.$greenf."[*]$cyanf List of this machine's ip4/6/MAC addresses:$reset\n";
foreach $a ( @own_addresses) { print cs_color( $a)."\n"; }
#print @own_addresses;
print $boldon.$greenf."[*]$cyanf These will be placed on the left if possible.$reset\n";

my %own_addresses_hash = map { $_ => 1 } @own_addresses;

my $DEBUG = 0;

sub arp_make_local_left {
	my $left = shift;
	my $tell = shift;
	my $right = shift;
	if ( exists( $own_addresses_hash{$right}) ) {
		return "$right: $left";
	} else {
		return "$left$tell$right";
	}
}

sub make_local_left {
	my $left_ip = shift;
	my $right_ip = shift;
	my $left_port = shift;
	my $right_port = shift;
	#print "left = $left_ip, right = $right_ip, lport = $left_port, rport = $right_port\n";
	if ($left_port) {
		$left_port = ".$left_port";
		$right_port = ".$right_port";
	} else {
		$left_port = "";
		$right_port = "";
	}

	my $swapped = "";
	my $dir = "->";

	if ( exists( $own_addresses_hash{$right_ip}) and not exists( $own_addresses_hash{$left_ip}) ) {
		# Swap values around, as I want traffic to look like:
		# local -> far_away
		# local <- far_away
		# Swap values around, as I want traffic to look like: local > far awar
		($left_ip, $right_ip) = ($right_ip, $left_ip);
		($left_port, $right_port) = ($right_port, $left_port);
		#$swapped = "SWAPPED: ";
		$dir = "<-"
	}
	# Insert country info:
	my $country = $gi->country_code_by_addr( $right_ip);
	if ( $country) { $country = " (".cs_color($country).") " }
	else { $country = "" }
	return "$swapped$left_ip$left_port $dir $right_ip$right_port$country";
}

while (<STDIN>) {
		if ( $DEBUG) {
		print "___\n";
		print $_;
		}

    if (m/^((?:[\d\-]+\s)?[\d:\.]+ )?([A-Z0-9]{2,}(?: \d+\.[\da-z]+(?=,))?)([ ,].*)/) {
        my $timestamp = $1;
        my $protocol = $2;
        $_ = "$3\n";

        print $whitef.$timestamp.$reset if $timestamp;
        print cs_color( $protocol);
    }
		
		# First shift things to the left before making it colourful
		s/(Request who-has .*)(tell )($ipv4_addr)/arp_make_local_left( $1, $2, $3)/ge;
    s/ (?<lip>$ipv4_addr)\.(?<lport>$port) > (?<rip>$ipv4_addr)\.(?<rport>$port)/" ".make_local_left( $+{lip}, $+{rip}, $+{lport}, $+{rport} )/ge;


    # Numeric IPV6 address and port
    #s/ $ipv6_addr\.\K$port(?=[ :,])?/\e[36m$&\e[0m/g;
    #s/(?<!seq) \K$ipv6_addr(?=[ :,])?/\e[34m$&\e[0m/g;

    # Numeric IPV4 address and port
    #s/ ($ipv4_addr)\.($port)([ :,])?/print " ".cs_color($1).".".cs_color($2).$3/ge;
    s/ ($ipv4_addr) > ($ipv4_addr)/" ".make_local_left( $1, $2)/ge;

    s/ ($ipv4_addr)\.($port)([ :,]){1}/" ".cs_color($1).".".cs_color($2).$3/ge;
    s/ ($ipv4_addr)([ ,:])/" ".cs_color($1).$2/ge;
    #s/ ($ipv4_addr)(\.$port) > ($ipv4_addr)(\.$port)([ :,])?/" ".fix_dir( $1, $2, $3, $4).$5/ge;
    #s/ $ipv4_addr\.\K$port(?=[ :,])?/cs_color($&)/ge;
    #s/(?<= )$ipv4_addr(?=[ :,])?/cs_color($&)/ge;

    # FQDN
    #s/ $fqdn\.\K$port(?=[ :,])?/\e[36m$&\e[0m/g;
    #s/(?<= )$fqdn(?=[ :,])?/\e[34m$&\e[0m/g;

    # Bridge
    #s/(?<= )($port)\.($ipv4_addr|$ipv6_addr)\.($port)(?=[ :,])/\e[36m$1\e[0m.\e[34m$2\e[0m.\e[36m$3\e[0m/g;
    #s/(?<= )($port)\.($ipv4_addr|$ipv6_addr)(?=[ :,])/\e[36m$1\e[0m.\e[34m$2\e[0m/g;

    # Packet data (tcpdump -x)
    #s/\s+0x$hex+(?=:)/\e[35m$&\e[0m/;

    # Warnings
    s/\[bad udp cksum[^\]]*\]/\e[31m$&\e[0m/;

		# tcp/udp/icmp
		s/( seq )(\d+):(\d+)/ $1.cs_color($2).":".cs_color($3)/ge;
		s/( seq )(\d+),/ $1.cs_color($2)/ge;
		s/(\], ack )(\d+)/ $1.cs_color($2-1, 1).$2.$reset/ge;
		s/(([\d\s]|[\]],) ack )(\d+)/ $1.cs_color($2, 1).$2.$reset/ge;
		# Need to study seq and ack more
		#s/( seq )(\d+)/ $1.cs_color($2)/ge;
		#s/( ack )(\d+)/ $1.cs_color($2-1)/ge;
		s/( Flags )(\[S\])/$1$greenf$2$reset/;
		s/( Flags )(\[S\.\])/$1$boldon$greenf$2$reset/;
		s/( Flags )(\[R\.\])/$1$redf$2$reset/;
		
		s/ (ICMP)/ $boldon$bluef$1$reset/;
		s/(udp port )(\d+)( unreachable)/"$redf$1$reset".cs_color($2)."$redf$3$reset"/e;
		s/(unreachable)/$redf$1$reset/;
		s/(echo request)/$greenf$1$reset/;
		s/(echo reply)/$boldon$greenf$1$reset/;
		
		s/ (Request [\w-]+)/ $greenf$1$reset/;
		s/ (Reply)/ $boldon$greenf$1$reset/;
		s/ (tcp \d+)/ $boldon$redf$1$reset/;
		s/ (UDP)/ $boldon$greenf$1$reset/;

    print;
}
