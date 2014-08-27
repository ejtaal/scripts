#!/usr/bin/perl
use strict;
### README ###
#
#tcpdump2ascii v2.11 (07/12/2001 codex@bogus.net)
#
#This is a small perl program which converts tcpdump hex values
#(using tcpdump -x option) to readable ascii characters (31> char <123).
#
#Characters outside this range is printed as a dot (".").
#
#Usage:
#
#	./tcpdump2ascii -h
#
#The "snoop" level is actually irrelevant at this point. Anything above 0 will
#produce verbose snoop-like output.
#
#-codex

### BUGS ###
#Known bugs in 2.11
#------------------
#
#Prints previous snoop output after current packet has been captured. The 
#reason tcpdump2ascii is doing this is due to the way it parses the output
#from tcpdump.
#
#This was intentional, because I needed a quick and dirty fix. Next major 
#version will probably have this fix unless someone fixes it before I do 
#(which would be nice, because then I don't have to do it).
#
#Instead of:
#
#	loop {
#		<wait for input and parse it>
#	}
#
#tcpdump2ascii should probably do:
#
#	loop {
#		<wait for tcpdump info line>
#		loop {
#			<gobble hex>
#		}
#		<print snoop details>
#	}
#
#
#

### Original script starts here ###
##
## takes tcpdump -x output and turns it into ASCII
##
## usage: tcpdump -l -x | tcpdump2ascii
##
## v1.00 9/9/1999
##	   + initial release
##
## v1.10 8/12/1999
##	   + changed code to use Getopt::Long
##	   + added -d (debug) option
##	   + added -l (line) option
##	   + added -s (suppress) option
##
## v2.00 10/3/2000
##	   + added "snoop-like" functionality
##	   + see BUGS file for known bugs
##
## v2.10 24/5/2000 
##         + bug fixed in TCP -snoop code
##         + options t,x,S by Artur.Silveira@rezo.com
##
## v2.11 07/12/2001
##         + buglet in hex parsing code, now ignore case (some people
##         + seem to use this program for more than tcpdump!)
##
## written by codex@bogus.net 1999
##
my $version="v2.11 07/12/2001 codex\@bogus.net";

use Socket;
use Getopt::Long;

my (@packet,$LINE,$SUPPRESS,$DEBUG,$dumpX,$http);
my ($snoop,$opt_s,$opt_h,$opt_v,$opt_d,$opt_l,$opt_x,$opt_t,$opt_S);

GetOptions(
	"v" => \$opt_v,
	"h" => \$opt_h,
	"d" => \$opt_d,
	"l" => \$opt_l,
	"s" => \$opt_s,
	"S" => \$opt_S,
	"t:s" => \$opt_t,
	"x:s" => \$opt_x,
	"snoop:s" => \$snoop,
);

my @protocol;

if($opt_d) {

	## currently does nothing
	##

	$DEBUG=1;
} else {
	$DEBUG=0;
}

if($opt_l) {
	$LINE=1; # dont print hexa bytes
} else {
	$LINE=0;
}

if($opt_s) {
	$SUPPRESS=1; # suppress packet header
} else {
	$SUPPRESS=0;
}

$dumpX=16; # default 16 bytes
if($opt_x eq "1") {
	$dumpX=16; # suppress packet header
} 
elsif ($opt_x eq "2"){
	$dumpX=32;
}

$http=0; # default 16 bytes
if($opt_t eq "n") {
	$http="n"; # suppress packet header
} 
elsif ($opt_t eq "t"){
	$http="r";
}



if($opt_h) {
	print "tcpdump2ascii, version $version\n";
	print "usage: tcpdump -l -x ... | tcpdump2ascii\n";
	print "	   tcpdump2ascii [-h | -v | -d | -s | -l | -snoop <level>] [<filename>]\n";
	print "	   -h : this text\n";
	print "	   -v : print version string \n";
	print "	   -d : print debugging info\n";
	print "	   -l : don't print hex dump\n";
	print "	   -s : suppress tcpdump information line\n";
	print "	   -t : n (detection de \\n), t (detection de \\r\\n http,etc)\n";
	print "	   -x : 1 (dump 16 bytes) 2 (dump 32 bytes); default 16 bytes)\n";
	print "	   -S : skip print header packet\n";
	print "	   -snoop : verbose output like snoop (levels 0-9)\n";
	exit(0);
}

if($opt_v) {
	print "tcpdump2ascii, version $version\n";
	exit(0);
}

## read from stdin
##

my $i = 0;
my $ascii = "";

while(<>){

	## print the tcpdump information
	##
	my $dumpline = $_;
	my $converted_hex = "";
	print "$dumpline";

	if ( $dumpline =~ m/^[0-9\s]*\d\d:\d\d:\d\d/) {
		$ascii .= $converted_hex;
		if ( $ascii ne '') { print "[$ascii]\n"; }
		#print "info line\n";
		# Looks like an info line:
		print $dumpline;
		$ascii = "";
	}
	
	#if ( $dumpline =~ m/0x[a-f0-9]+:\s*([\sa-f0-9]+)([^\s]{10})$/ig) {
	if ( $dumpline =~  m/0x[a-f0-9]+:\s*([\sa-f0-9]+)\s([^\s]{10,})$/ig) {
		#print "prefixed line\n";
		# Looks like a hex prefixed ascii line
		my $hex = $1;
		my $append = $2;
		#print "hex before: [$hex]\n";
		$hex =~ s/\s//g;
		#print "hex after: [$hex]\n";
		$converted_hex = $hex;
		$converted_hex =~ s/([a-fA-F0-9][a-fA-F0-9])/map_chars($1)/eg;
		#$ascii .= $hex;
		if ( $hex =~ m/0a/) {
			#print "0a found at: ";
			my $nl = index( $hex,"0a");
			#if ( $nl > -1 ) { print "$nl\n"; }
			#else { print "NO\n"; }
			if ($nl > -1 && $nl % 2 == 0 ) {
				#print "ascii is now ". length( $ascii) ." bytes long";
				$ascii .= substr( $converted_hex, 0, (($nl / 2)));
				#if ( length( $ascii) > 20 ) { $hex =~ s/([a-fA-F0-9][a-fA-F0-9])/map_chars($1)/eg; }
				if ( length( $ascii) > 30 ) { $ascii .= "\n"; }
				$ascii .= substr( $converted_hex, (($nl / 2) + 1) );
			} else {
				$ascii .= $converted_hex;
			}
		} else {
			$ascii .= $converted_hex;
		}
	}
}

if ( $ascii ne '') { print "[$ascii]\n"; }

exit(0);

sub map_chars {
	my ($hex_char) = @_;
	#$i++;
	my $r = "";
	my $no = hex( $hex_char);
	if ( $no == 10 ) { $r = "\n" }
	elsif ( $no < 32 || $no > 123) { $r = "_" }
	else { $r = chr($no) }

	#print "i = [$i], hex_char = [$hex_char], r = [$r]\n";
	return $r;
	
}
