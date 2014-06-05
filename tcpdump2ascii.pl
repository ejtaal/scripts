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
my ($snoop,$opt_d,$opt_s,$opt_h,$opt_v,$opt_d,$opt_l,$opt_x,$opt_t,$opt_S);

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

AssignedNumbers();

## read from stdin
##


@packet = ();
my $i = 0;

while(<>){

	## print the tcpdump information
	##

	(my $info)=/^(\d\d:\d\d:\d\d\.\d+ .*)/;

	if($info) {
		&printBody if($packet[0]);
		@packet = ();
		$i = 0;

		if($packet[0] && $snoop) {
			ShowInfo();
		}

		if($SUPPRESS) {
			print "\n";
		} else {
			print "\n\n$info\n";
			$info="";
		}

	} 
	else {
		## grab hex information
		while(/([a-f0-9][a-f0-9])/ig) {
			$packet[$i]=$1;
			$i++;
		}
	}
}

&printBody if($packet[0]); # flush the last data

exit(0);

sub comPDumpX {
	return if (!$http);
}
sub printBody {
	my $j;
	if($packet[0]) {

		for(my $k=$opt_S?52:0;$k<$i;$k+=$dumpX) {
			my $l;
			if ($http) {
				# search mode \\n or \\r\\n
				$dumpX = 0;
				SEARCH: for ($l=$k;$l<$i;$l++)  {
					if ($http eq "t") {
						if (($packet[$l] eq "0d") && ($packet[$l + 1] eq "0a")) {
							$dumpX = $l - $k + 2;
							last SEARCH;
						}
					}
					elsif ($packet[$l] eq "0a") { # http eq "n"
						$dumpX = $l - $k + 1;
						last SEARCH;
					}
				}
				$dumpX = $l - $k + 1 unless ($dumpX);

			}

			## print hex info if not in line mode
			if(!$LINE) {
				for($j=$k;$j<$k+$dumpX;$j++) {
					if(length($packet[$j])==2) {
						print "$packet[$j]";
					} 
					else {
						print "$packet[$j]--";
					} 
					print " " if ($j%2);
				}
				print " |  ";
			}
	
			## do the conversion & print
			for($j=$k;$j<$k+$dumpX;$j++) {
				my @h;
				$_=$packet[$j];
	
				## buggy ($h[0],$h[1])=/(\S\S)(\S\S)/;
				## fix by David Slimp <rock@cyberclub.com>
	
				#($h[0],$h[1])=/\s*(\S\S)(\S\S)?/;
		
				my $h;
				if(hex($packet[$j])>31 && hex($packet[$j])<123) {
					$h=chr(hex($packet[$j]));
				} 
				else {
					if(hex($packet[$j]) == 10) {
						$h="\\n";
					}
					elsif (hex($packet[$j]) == 13) {
						$h="\\r";
					}
					elsif (hex($packet[$j]) == 9) {
						$h="\\t";
					}
					else {
						$h=".";
					}
				}
				if(length($h) == 1) {
					if(!$LINE) {
						print "$h ";
					} 
					else {
						print "$h";
					}
				}
				else {
					print "$h";
				}
			}
			if($http) {
				print "\n";
			}
			elsif (!$LINE) {
				print "\n";
			}
		}
	}

}


## this is a really slow way of doing things. this is a prototype, so you can
## forget telling me that i am doing things pathetically, ok? i just needed
## "snoop" for linux.
##

sub ShowInfo {
	my($proto,$version);

	my $ipv4=PrintBit0($packet[0]); ## IP version, header length, type of service

	if(!$ipv4) {
	undef(@packet);
	return;
	}

	PrintBit16($packet[1]); ## total packet length in bytes
	PrintBit32($packet[2]); ## header id
	PrintBit48($packet[3]); ## 3bit flags, 13-bit fragment offset
	$proto=PrintBit64($packet[4]); ## TTL, protocol
	PrintBit80($packet[5]); ## header checksum
	PrintBit96("$packet[6]$packet[7]"); ## source address
	PrintBit128("$packet[8]$packet[9]"); ## destination address
	if($proto eq "UDP") {ShowUDP();}
	if($proto eq "TCP") {ShowTCP();}
	print "+-------------------------------------------------------------------------+\n";
	undef(@packet);
}

## bits 0-15
## 
sub PrintBit0 {
	my($word)=@_;

	my($lbyte)=hex(substr($word,0,2)); ## version/length
	my($rbyte)=substr($word,2,2); ## tos
	
	my($lbin)=Dec2Bin($lbyte);
	$lbin=substr($lbin,24,8);

	my($lnybble)=substr($lbin,0,4);
	my($version)=Bin2Dec($lnybble);

	if($version!=4) {return(0);}

	print "+-------------------------------------------------------------------------+\n";
	print "|	   IP version: $version\n";
	print "|			  TOS: 0x$rbyte\n";
	return(1);
}

## bits 16-31
##
sub PrintBit16 {
	my($word)=@_;
	my($length)=hex($word);
	print "| IP header length: $length bytes\n";
}

## bits 32-47
##
sub PrintBit32 {
	my($word)=@_;
	my($dec)=hex($word);
	my($bin)=Dec2Bin($dec);
	$bin=~s/^0+(?=\d)//;
	print "|		header id: 0x$word , $dec , $bin\n";
}

## bits 48-63
##
sub PrintBit48 {
	my($word)=@_;
	my($bin)=Dec2Bin(hex($word));
	my($flags)=substr($bin,16,3);
	my($bf_offset)=substr($bin,19,13);
	$bf_offset=~s/^0+(?=\d)//; ## strip leading zeroes
	my($df_offset)=Bin2Dec($bf_offset);
	my($hf_offset)=oct("0b".$bf_offset);
	print "|		 IP flags: $flags\n";
	print "|  fragment offset: 0x$hf_offset , $df_offset , $bf_offset\n";
}

## bits 64-79
##
sub PrintBit64 {
	my($word)=@_;
	my($lbyte)=substr($word,0,2);
	my($rbyte)=substr($word,2,2);
	my($dlbyte)=hex($lbyte);
	my($drbyte)=hex($rbyte);
	my $proto=GetProto($drbyte);
	print "|			  TTL: 0x$lbyte , $dlbyte\n";
	print "|		 protocol: 0x$rbyte , $drbyte ($proto)\n";
	return($proto);
}

## bits 80-95
##
sub PrintBit80 {
	my($word)=@_;
	print "|		 checksum: 0x$word\n";
}

## bits 96-127
##
sub PrintBit96 {
	my($lword)=@_;
	my($src)=pack("N",hex($lword));
	my($src)=inet_ntoa($src);
	print "|	  src address: $src\n";
}

## bits 128-159
## 
sub PrintBit128 {
	my($lword)=@_;
	my($dst)=pack("N",hex($lword));
	my($dst)=inet_ntoa($dst);
	print "|	  dst address: $dst\n";
}

## TCP header
## 

sub ShowTCP {
	PrintTCPBit0($packet[10]); ## src port
	PrintTCPBit16($packet[11]); ## dst port
	PrintTCPBit32("$packet[12]$packet[13]"); ## sequence number
	PrintTCPBit64("$packet[14]$packet[15]"); ## ack number
	PrintTCPBit96($packet[16]); ## 4bit header length, flags
	PrintTCPBit112($packet[17]); ## window size
	PrintTCPBit128($packet[18]); ## checksum
	PrintTCPBit144($packet[19]); ## urgent pointer
}

sub PrintTCPBit0 {
	my($word)=@_;
	my($sport)=hex($word);
	my($service)=getservbyport($sport,"tcp");
	if(!$service) {$service="unknown";}
	print "|	 TCP src port: $sport ($service)\n";
}
sub PrintTCPBit16 {
	my($word)=@_;
	my($dport)=hex($word);
	my($service)=getservbyport($dport,"tcp");
	if(!$service) {$service="unknown";}
	print "|	 TCP dst port: $dport ($service)\n";
}
sub PrintTCPBit32 {
	my($lword)=@_;
	my($dword)=hex($lword);
	print "| TCP sequence no.: 0x$lword , $dword\n";
}
sub PrintTCPBit64 {
	my($lword)=@_;
	my($dword)=hex($lword);
	print "|	 TCP ack. no.: 0x$lword , $dword\n";
}
sub PrintTCPBit96 {
	my($word)=@_;
	my($bin)=substr(Dec2Bin(hex($word)),16,16);
	my($blength)=substr($bin,0,4);
	print "|  TCP header bits: $blength\n";
	my($resflags)=substr($bin,4,6);
	print "| TCP resrvd flags: $resflags\n";
	my($flagbits)=substr($bin,10,6);
	my $flags=GetFlags($flagbits);
	print "|		TCP flags: $flagbits $flags\n";
}
sub PrintTCPBit112 {
	my($word)=@_;
	my($bsize)=hex($word);
	print "|  TCP window size: 0x$word , $bsize bytes\n";
}
sub PrintTCPBit128 {
	my($word)=@_;
	print "|	 TCP checksum: 0x$word\n";
}
sub PrintTCPBit144 {
	my($word)=@_;
	print "|  TCP URG pointer: 0x$word\n";
}

## english representation of TCP flags
##

sub GetFlags {
	my($fb)=@_;
	my($flags)="";
	if(substr($fb,0,1)==1) {$flags="URG ";}
	if(substr($fb,1,1)==1) {$flags=$flags."ACK ";}
	if(substr($fb,2,1)==1) {$flags=$flags."PSH ";}
	if(substr($fb,3,1)==1) {$flags=$flags."RST ";}
	if(substr($fb,4,1)==1) {$flags=$flags."SYN ";}
	if(substr($fb,5,1)==1) {$flags=$flags."FIN";}
	return($flags);
}

## UDP header
##

sub ShowUDP {
	PrintUDPBit0($packet[10]); ## src port
	PrintUDPBit16($packet[11]); ## dst port
	PrintUDPBit32($packet[12]); ## length
	PrintUDPBit48($packet[13]); ## checksum
}

sub PrintUDPBit0 {
	my($word)=@_;
	my($sport)=hex($word);
	my($service)=getservbyport($sport,"udp");
	if(!$service) {$service="unknown";}
	print "|	 UDP src port: $sport ($service)\n";
}
sub PrintUDPBit16 {
	my($word)=@_;
	my($dport)=hex($word);
	my($service)=getservbyport($dport,"udp");
	if(!$service) {$service="unknown";}
	print "|	 UDP dst port: $dport ($service)\n";
}
sub PrintUDPBit32 {
	my($word)=@_;
	my($plen)=hex($word);
	print "|	   UDP length: $plen bytes\n";
}
sub PrintUDPBit48 {
	my($word)=@_;
	print "|	 UDP checksum: 0x$word \n";
}

## convert protocol number to name
##

sub GetProto {
	my($num)=@_;
	return(@protocol[$num]);
}

## convert decimal to binary
##

sub Dec2Bin {
	my($dec)=@_;
	my($foo);
	$foo=unpack("B32",pack("N",$dec));
	return($foo);
}

## convert binary to decimal
##

sub Bin2Dec {
	my($bin)=@_;
	my($foo)=unpack("N",pack("B32",substr("0" x 32 . $bin,-32)));
}

## assigned numbers, from rfc 1700
##

sub AssignedNumbers {
	my($i);
	@protocol[0]="Reserved";
	@protocol[1]="ICMP";
	@protocol[2]="IGMP";
	@protocol[3]="GGP";
	@protocol[4]="IP";
	@protocol[5]="ST";
	@protocol[6]="TCP";
	@protocol[7]="UCL";
	@protocol[8]="EGP";
	@protocol[9]="IGP";
	@protocol[10]="BBN-RCC-MON";
	@protocol[11]="NVP-II";
	@protocol[12]="PUP";
	@protocol[13]="ARGUS";
	@protocol[14]="EMCON";
	@protocol[15]="XNET";
	@protocol[16]="CHAOS";
	@protocol[17]="UDP";
	@protocol[18]="MUX";
	@protocol[19]="DCN-MEAS";
	@protocol[20]="HMP";
	@protocol[21]="PRM";
	@protocol[22]="XNS-IDP";
	@protocol[23]="TRUNK-1";
	@protocol[24]="TRUNK-2";
	@protocol[25]="LEAF-1";
	@protocol[26]="LEAF-2";
	@protocol[27]="RDP";
	@protocol[28]="IRTP";
	@protocol[29]="ISO-TP4";
	@protocol[30]="NETBLT";
	@protocol[31]="MFE-NSP";
	@protocol[32]="MERIT-INP";
	@protocol[33]="SEP";
	@protocol[34]="3PC";
	@protocol[35]="IDPR";
	@protocol[36]="XTP";
	@protocol[37]="DDP";
	@protocol[38]="IDPR-CMTP";
	@protocol[39]="TP++";
	@protocol[40]="IL";
	@protocol[41]="SIP";
	@protocol[42]="SDRP";
	@protocol[43]="SIP-SR";
	@protocol[44]="SIP-FRAG";
	@protocol[45]="IDRP";
	@protocol[46]="RSVP";
	@protocol[47]="GRE";
	@protocol[48]="MHRP";
	@protocol[49]="BNA";
	@protocol[50]="SIPP-ESP";
	@protocol[51]="SIPP-AH";
	@protocol[52]="I-NLSP";
	@protocol[53]="SWIPE";
	@protocol[54]="NHRP";
	@protocol[61]="AnyHostInternalProtocol";
	@protocol[62]="CFTP";
	@protocol[63]="AnyLocalNetwork";
	@protocol[64]="SAT-EXPAK";
	@protocol[65]="KRYPTOLAN";
	@protocol[66]="RVD";
	@protocol[67]="IPPC";
	@protocol[68]="AnyDistributedFileSystem";
	@protocol[69]="SAT-MON";
	@protocol[70]="VISA";
	@protocol[71]="IPCV";
	@protocol[72]="CPNX";
	@protocol[73]="CPHB";
	@protocol[74]="WSN";
	@protocol[75]="PVP";
	@protocol[76]="BR-SAT-MON";
	@protocol[77]="SUN-ND";
	@protocol[78]="WB-MON";
	@protocol[79]="WB-EXPAK";
	@protocol[80]="ISO-IP";
	@protocol[81]="VMTP";
	@protocol[82]="SECURE-VMTP";
	@protocol[83]="VINES";
	@protocol[84]="TTP";
	@protocol[85]="NSFNET-IGP";
	@protocol[86]="DGP";
	@protocol[87]="TCF";
	@protocol[88]="IGRP";
	@protocol[89]="OSPFIGP";
	@protocol[90]="Sprite-RPC";
	@protocol[91]="LARP";
	@protocol[92]="MTP";
	@protocol[93]="AX.25";
	@protocol[94]="IPIP";
	@protocol[95]="MICP";
	@protocol[96]="SCC-SP";
	@protocol[97]="ETHERIP";
	@protocol[98]="ENCAP";
	@protocol[99]="AnyPrivateEncryptionScheme";
	@protocol[100]="GMTP";
	@protocol[255]="Reserved";
	for($i=55;$i<61;$i++) {
	@protocol[$i]="Unassigned";
	}
	for($i=101;$i<255;$i++) {
	@protocol[$i]="Unassigned";
	}
}




