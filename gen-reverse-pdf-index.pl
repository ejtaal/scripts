#!/usr/bin/perl
=pod

Requirements:
Extract a pdf using pdftohtml -xml <pdffile> <output.xml>
Tweak output.xml etc to start with the index text.

Usage:

cat tweakedxmlfile.xml | gen-reverse-pdf-index.pl


Test command:

Based on:

=cut

# This script does need these libs installed please:
# apt-get install libstring-crc-cksum-perl libgeo-ip-perl
# If it's not in apt-cache or yum then do from the terminal:
# cpan> install String::CRC::Cksum
# cpan> install Geo::IP


use strict;
#use warnings;

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

my $page_items;

sub extract_page_numbers {
	#print "1 = [$1]\n";
	my $s = shift;
	my $heading = shift;
	my $heading2 = shift;
	my $heading3 = shift;
	# remove page ranges
	$s =~ s/(\d+)[a-z]*-\d[\d\w]+/$1/g;
	# remove page suffixes (for tables, images etc)
	$s =~ s/\s*(\d+)[a-z]/ $1/g;
	if ( $s =~ m/^(.*?),\s*\d/) {
		# Seems like a valid line
		my $item = $1;
		my $lastpageno = 0;
		while ($s =~ /,\s*(\d+)/g) {
			my $pageno = $1;
			if ( $pageno == $lastpageno) { next; }
			if ( $heading3 ne "") {
				print "ITEM: $pageno, ($heading, $heading2, $heading3, $item)\n";
				}
			elsif ( $heading2 ne "") {
				print "ITEM: $pageno, ($heading, $heading2, $item)\n";
				}
			elsif ( $heading ne "") {
				print "ITEM: $pageno, ($heading, $item)\n";
				}
			else { print "ITEM: $pageno, $item\n" };
			$lastpageno = $pageno;
			$page_items++;
		}
		return 0;
	} else {
		print "=> UNRECOGNIZED LINE: [$s]\n";
		return 1;
	}
}

my $tabs = "    ";
my $DEBUG = 1;
my $lasttop = 0, my $lastleft = -1; my $lastwidth = 0;
my $lasttext = "", my $lastitemtext = "", my $itemtext = "";
my $redirect = 0, my $itemheading = "", my $itemheading2 = "", my $itemheading3;
my $last_indent = 0, my $isindent = 0;
my %big_index;
# Could do with receiving a seed value through argv[1] or something
my $avg_indent = 11.000; my $indents_found = 1;
# Could also do with a seed:
my $avg_column_shift = 270.000; my $columns_found = 1;
my $last_column_left = 0; my $cur_column = 0;
my $cur_page = 0; my $cur_page_line = 0; my $even_odd_page;
my $page_non_garbage_line = 0;
my $page_height; my $page_width;

# 2 dim array, @[0] for even pages @[1] for odd ones
# This needs to be either detected or sussed out beforehand and given
# as a parameter somehow
# Also, this obviously implies all even/odd pages of the index have roughly
# the same layout.
my @column_left = ( [ 0, 54, 324, 594], [ 0, 81, 351, 621]);

my $cur_outline_indent = 0;
my $outline_line = 0;


#use Math::round;
use Data::Dumper;

while (<STDIN>) {
	chomp;
	if ( $DEBUG) {
		print "=> [".$_."]\n";
	}

	if ( m|^<page.*?number="(\d+)".*?height="(\d+)".*?width="(\d+)"| ) {
		# New page
		$cur_page = $1;
		$page_height = $2;
		$page_width = $3;
		$page_items = 0;
		$cur_page_line = 0;
		$page_non_garbage_line = 0;

		print "=> NEW PAGE: $cur_page\n";
		$even_odd_page = $cur_page % 2;

		#if ( $columns_found < 2) { next; }
#		# Add stats:
#		$avg_column_shift = ($avg_column_shift * $columns_found + ($column_left[$cur_column] - $column_left[$cur_column-1])) / ($columns_found + 1);
#		#print "=> COLUMN INFO UPDATE, columns_found: $columns_found, avg_column_shift: $avg_column_shift\n";
#		print "=> column_left:\n";
#		print Dumper \@column_left;
		# Arbitrary large value;
		$cur_column = 0;
		# New column will be detected again below to do ++
	}
	elsif ( m|^<text top="(\d+)" left="(\d+)".*?width="(\d+)".*?font="(\d+)".*?>(.*?)$| ) {
		$cur_page_line++;
		my $top = $1;
		my $left = $2;
		my $width = $3;
		my $font = $4;
		my $text = $5;
		$text =~ s/<\/text>//;
		$text =~ s/<\/*(b|i)>//g;
		#print "=> cur_page_line: $cur_page_line, page_height * 0.05: ".($page_height * 0.05)."\n";
		if ( $font > 6 or $text =~ m|^[\s,\.\(\)\[\]]*$|
			or ( $cur_page_line < 20 && $left > 500)
			or ( $cur_page_line < 20 and ( $left < $column_left[ $even_odd_page][1] or $top < ($page_height * 0.05)) ) # don't trust stuff left from seen before or in top margin
			) { 
			print "=> GARBAGE LINE, next!\n";
			next;
			}
		$page_non_garbage_line++;
		# Register some initial left values
		# if ( $lastleft < 0) { $lastleft = $left; $last_column_left = $left }

		#print "Text detected, t: $top l: $left [$text]\n";
		if ( $text =~ m|^(.*?),\s*\d| ) { $itemtext = $1; }
		#if ( $text =~ m|^(.*?),\s*\d| ) { $itemtext = $1; }
		else { $itemtext = $text; }


		# Try to detect new column/pages?
		#         following line feed       new column                    unindent                   large indent = new column
		#if ( (abs( $top - $lasttop) > 5 || ($lasttop - $top) > 100 ) && (($lastleft - $left) > 5 || ($left - $lastleft) > 100)) {
			# new line, or new column
		#	print "\nNEW LINE / HEADING: $text\n";
		#}


		# New column or page?
		#print "=> lasttop: $lasttop, top: $top, lastleft: $lastleft, left: $left\n";
		if ( ( $lasttop - $top) > 250 or $page_non_garbage_line == 1) {
			if ( ($left - $lastleft) > 100 or $page_non_garbage_line == 1) {
				# New column
				$cur_column++;
				my $expected_left = $column_left[ $even_odd_page][ $cur_column];
				my $indent_guess = sprintf( "%.0f", ($left - $expected_left) / $avg_indent);
				print "=> NEW COLUMN (expected: $expected_left, actual: $left, indent_guess = $indent_guess): $text\n";
				print "=> cur_column = $cur_column\n";

#				if ( $cur_column > 2) {
#					# Add stats:
#					$columns_found++; # In terms of stats generation, i.e. 1-2, 2-3, 3-4 etc so actually column_shifts_found
#					$avg_column_shift = ($avg_column_shift * $columns_found + ($column_left[$cur_column-1] - $column_left[$cur_column-2])) / ($columns_found + 1);
#					print "=> COLUMN INFO UPDATE, columns_found: $columns_found, avg_column_shift: $avg_column_shift\n";
#				}


				# Fudge to detect continuation of a sub/subsub heading (won't always work):
				if ( $indent_guess > 0 or $text =~ m/\s(in|of|as|and|due to),/ or $text =~ m/^(with|in|of|for)\s/ or $text =~ m|^[a-z]|) {
					# Possibly continuation of a subheading from previous column's end
					# Don't reset indent etc.
					print "=> CONTINUATION OF SUB/SUBSUB heading detected: $text\n";
					if ( $isindent > 0 and $indent_guess > 0) {
						$isindent = $indent_guess;
					}
				}
				else { # We have to assume this is a new heading etc.
					# completely new line, or new column
					print "\n=> NO SUBHEADING DETECTED: $text\n";
					$redirect = 0;
					$isindent = 0;
					$itemheading = $itemtext;
				}
			}
			# Large shift to left, end of page?
			elsif ( ($lastleft - $left ) > 250 ) {
				print "=> LARGE LEFT SHIFT, end of page? next!\n";
				next;
			}
		}

		# New indent?
		elsif ( $page_non_garbage_line != 1 && abs( $top - $lasttop) > 5 && ($left - $lastleft > 5) ) {
			#print "==>> page_items: $page_items\n";
			if ( $isindent == 2) {
				print "=> SUBSUBSUB heading: $text ($itemheading, $itemheading2, $itemheading3)\n";
				# Set itemheading4? ;)
				$isindent = 3;
				}
			elsif ( $isindent == 1) {
				print "=> SUBSUB HEADING: $text ($itemheading, $itemheading2)\n";
				$itemheading3 = $itemtext;
				$isindent = 2;
				}
			else {
				print "=> SUB HEADING: $text\n";
				$itemheading2 = $itemtext;
				$isindent = 1;
			}
#			# Keep running score of average indent amount to detect back-indents properly
#			# But only if it's a subheading with numbers
#			if ( $text =~ m|[,\s]\d|) {
#				$avg_indent = ($avg_indent * $indents_found + ($left-$lastleft)) / ($indents_found + 1);
#				$indents_found++;
#				print "=> INDENT INFO UPDATE, indents_found: $indents_found, avg_indent: $avg_indent\n";
#			} else {
#				print "=> NOT COUNTING THIS INDENT\n";
#			}
		}
		# If same column and already indented, update itemheading2
		elsif ( abs( $left - $lastleft) < 5 ) {
			if    ( $isindent == 0 ) { $itemheading   = $itemtext; }
			if    ( $isindent == 1 ) { $itemheading2  = $itemtext; }
			if    ( $isindent == 2 ) { $itemheading3  = $itemtext; }
			#elsif ( $isindent == 2 ) { $itemheading2 = $itemtext; }
		}
		# Try to detect un-indents instead of new headings:
		#      regular new line              already indented before && now unindented
		elsif (abs( $top - $lasttop) < 50 && $isindent > 0 && ($lastleft - $left) > 5) {
			#print "\nNEW LINE / HEADING: $text\n";
			my $unindents = sprintf( "%.0f", ($lastleft - $left) / $avg_indent);
			
			my $expected_left = $column_left[ $even_odd_page][ $cur_column];
			my $indent_guess = sprintf( "%.0f", ($left - $expected_left) / $avg_indent);
			
			print "=> UNINDENT DETECTED, AMOUNT: $unindents\n";

			$isindent -= $unindents;
			if ( $isindent < 0 ) { $isindent = 0; }
			if ( $isindent != $indent_guess ) {
				print "=> (p$cur_page,l$cur_page_line) UNINDENT GUESS DIFFERENT FROM HARD CODED INDENT GUESS: $isindent vs $indent_guess\n";
				# Sorry Unindent, your guesses are off most of the time. Overruled!
				$isindent = $indent_guess;
			}
			if    ( $isindent == 0 ) { $itemheading   = $itemtext; }
			if    ( $isindent == 1 ) { $itemheading2  = $itemtext; }
			if    ( $isindent == 2 ) { $itemheading3  = $itemtext; }
		}
		# If start of this line is within 5 pix radius of end of last line assume it's continuation
		elsif (abs( $top - $lasttop) < 5 and abs( $left - ($lastleft + $lastwidth)) < 5 ) {
			print "=> CONTINUATION OF UNFINISHED LINE\n";
			# Do same as LONE PAGENO below
			$isindent = $last_indent; 
			$text = "$lasttext $text";
			print "=> Reverted to: $text\n";
			
			# Fix all indent headers:
			if ( $text =~ m|^(.*?),\s*\d| ) { $itemtext = $1; }
			else { $itemtext = $text; }
			
			# To stop routine above thinking it's a new line / new heading:
			$left = $lastleft;
			$top = $lasttop;
			if    ( $isindent == 0 ) { $itemheading   = $itemtext; }
			if    ( $isindent == 1 ) { $itemheading2  = $itemtext; }
			if    ( $isindent == 2 ) { $itemheading3  = $itemtext; }
		}
		else {
			# completely new line
			print "\n=> COMPLETELY NEW LINE: $text\n";
			$redirect = 0;
			$isindent = 0;
			$itemheading = $itemtext;
		}
		print "=> INDENTS: $isindent, $itemheading, $itemheading2, $itemheading3\n";
		
		# Index alphabet headers
		if ( $text =~ m|^[A-Z]$| ) { $isindent = 0; }
		# Lone line of page number(s) for previous item
		#if ( $text =~ m|^[,\s\d]+$| ) {
		# Starts with numbers but that could also be part of the heading itself
		if ( $text =~ m|^\d| and $text !~ m|[A-Za-z].*?,\s*\d|) {
			print "=> LONE PAGENO LINE: $text\n";
			$isindent = $last_indent; 
			$text = "$lasttext, $text";
			print "=> Reverted to: $text\n";
			# To stop routine above thinking it's a new line / new heading:
			$left = $lastleft;
			$top = $lasttop;
		}

		# Got page numbers?
		if ( $text =~ m|\d+| ) { 
			#print "NUM";
			if    ( $isindent == 3) { extract_page_numbers( $text, $itemheading, $itemheading2, $itemheading3) }
			elsif    ( $isindent == 2) { extract_page_numbers( $text, $itemheading, $itemheading2) }
			elsif ( $isindent == 1) { extract_page_numbers( $text, $itemheading, "") }
			else                    { extract_page_numbers( $text, "", "") }
			}
		# no numbers found, could be a heading, or redirect?
		elsif ( $text =~ m|See\s| ) {
			# index item that 'redirects', ignore it
			print "=> REDIRECT: 'See' detected\n";
			$redirect = 1; 
		}
		$lasttop = $top;
		$lastleft = $left;
		$lastwidth = $width;
#		if ( $left < $column_left[ $even_odd_page][ $cur_column] ) { 
#			print "=> LEFT UPDATED: [$even_odd_page][$cur_column]:\n";
#			$column_left[ $even_odd_page][ $cur_column] = $left;
#			print Dumper \@column_left;
#		}
		$lasttext = $text;
		$lastitemtext = $itemtext;
		$last_indent = $isindent;
	}
	elsif ( m|^</outline| ) {
		$cur_outline_indent--;
	}
	elsif ( m|^<outline| ) {
		$cur_outline_indent++;
	}
	elsif ( m|^<item page="(\d+)">(.*?)</item| ) {
		my $target_page = $1;
		my $header = $2;
		$outline_line++;
		my $prefixed_num = sprintf( "%09d", $outline_line);
		#print "OUTLINE: $target_page, ". "\t"x$cur_outline_indent ."$prefixed_num"."_"."$header\n";
		print "OUTLINE: $target_page, $prefixed_num "."=="x$cur_outline_indent ."$header\n";
	}
}
