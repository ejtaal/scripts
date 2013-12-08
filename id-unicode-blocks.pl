#!/usr/bin/env perl
# 
# This script attempts to solve the problem of trying
# to differentiate the following 2 lines:
# 
# all_roots=['ﺍ','ﺁﺍ','ﺍﺑ','ﺍﺑﺍ','ﺍﺒﺑ','ﺍﺒﺗ','ﺍﺒﺟﺩ'];
# all_roots=['ا','ﺁا','ﺎﺑ','ﺎﺑا','ﺎﺒﺑ','ﺎﺒﺗ','ﺎﺒﺟﺩ'];
# 
# Can you spot the difference? 
# head 
# 
# 
# 
# 
# 
# 
# 

use strict;
use utf8;
use Encode;
use open qw(:std :utf8);
use Unicode::UCD 'charinfo';

my $DEBUG = 1;
$DEBUG = 0;
use warnings;

my $option = $ARGV[0];
my $summary_only = 0;
if ( $option eq '-s' ) {
	$summary_only = 1;
}

# http://www.unicode.org/Public/UNIDATA/Blocks.txt
my %m;
$m{"Basic Latin"} = qr/[\N{U+0000}-\N{U+007F}]/u;
$m{"Latin-1 Supplement"} = qr/[\N{U+0080}-\N{U+00FF}]/u;
$m{"Latin Extended-A"} = qr/[\N{U+0100}-\N{U+017F}]/u;
$m{"Latin Extended-B"} = qr/[\N{U+0180}-\N{U+024F}]/u;
$m{"IPA Extensions"} = qr/[\N{U+0250}-\N{U+02AF}]/u;
$m{"Spacing Modifier Letters"} = qr/[\N{U+02B0}-\N{U+02FF}]/u;
$m{"Combining Diacritical Marks"} = qr/[\N{U+0300}-\N{U+036F}]/u;
$m{"Greek and Coptic"} = qr/[\N{U+0370}-\N{U+03FF}]/u;
$m{"Cyrillic"} = qr/[\N{U+0400}-\N{U+04FF}]/u;
$m{"Cyrillic Supplement"} = qr/[\N{U+0500}-\N{U+052F}]/u;
$m{"Armenian"} = qr/[\N{U+0530}-\N{U+058F}]/u;
$m{"Hebrew"} = qr/[\N{U+0590}-\N{U+05FF}]/u;
$m{"Arabic"} = qr/[\N{U+0600}-\N{U+06FF}]/u;
$m{"Syriac"} = qr/[\N{U+0700}-\N{U+074F}]/u;
$m{"Arabic Supplement"} = qr/[\N{U+0750}-\N{U+077F}]/u;
$m{"Thaana"} = qr/[\N{U+0780}-\N{U+07BF}]/u;
$m{"NKo"} = qr/[\N{U+07C0}-\N{U+07FF}]/u;
$m{"Samaritan"} = qr/[\N{U+0800}-\N{U+083F}]/u;
$m{"Mandaic"} = qr/[\N{U+0840}-\N{U+085F}]/u;
$m{"Arabic Extended-A"} = qr/[\N{U+08A0}-\N{U+08FF}]/u;
$m{"Devanagari"} = qr/[\N{U+0900}-\N{U+097F}]/u;
$m{"Bengali"} = qr/[\N{U+0980}-\N{U+09FF}]/u;
$m{"Gurmukhi"} = qr/[\N{U+0A00}-\N{U+0A7F}]/u;
$m{"Gujarati"} = qr/[\N{U+0A80}-\N{U+0AFF}]/u;
$m{"Oriya"} = qr/[\N{U+0B00}-\N{U+0B7F}]/u;
$m{"Tamil"} = qr/[\N{U+0B80}-\N{U+0BFF}]/u;
$m{"Telugu"} = qr/[\N{U+0C00}-\N{U+0C7F}]/u;
$m{"Kannada"} = qr/[\N{U+0C80}-\N{U+0CFF}]/u;
$m{"Malayalam"} = qr/[\N{U+0D00}-\N{U+0D7F}]/u;
$m{"Sinhala"} = qr/[\N{U+0D80}-\N{U+0DFF}]/u;
$m{"Thai"} = qr/[\N{U+0E00}-\N{U+0E7F}]/u;
$m{"Lao"} = qr/[\N{U+0E80}-\N{U+0EFF}]/u;
$m{"Tibetan"} = qr/[\N{U+0F00}-\N{U+0FFF}]/u;
$m{"Myanmar"} = qr/[\N{U+1000}-\N{U+109F}]/u;
$m{"Georgian"} = qr/[\N{U+10A0}-\N{U+10FF}]/u;
$m{"Hangul Jamo"} = qr/[\N{U+1100}-\N{U+11FF}]/u;
$m{"Ethiopic"} = qr/[\N{U+1200}-\N{U+137F}]/u;
$m{"Ethiopic Supplement"} = qr/[\N{U+1380}-\N{U+139F}]/u;
$m{"Cherokee"} = qr/[\N{U+13A0}-\N{U+13FF}]/u;
$m{"Unified Canadian Aboriginal Syllabics"} = qr/[\N{U+1400}-\N{U+167F}]/u;
$m{"Ogham"} = qr/[\N{U+1680}-\N{U+169F}]/u;
$m{"Runic"} = qr/[\N{U+16A0}-\N{U+16FF}]/u;
$m{"Tagalog"} = qr/[\N{U+1700}-\N{U+171F}]/u;
$m{"Hanunoo"} = qr/[\N{U+1720}-\N{U+173F}]/u;
$m{"Buhid"} = qr/[\N{U+1740}-\N{U+175F}]/u;
$m{"Tagbanwa"} = qr/[\N{U+1760}-\N{U+177F}]/u;
$m{"Khmer"} = qr/[\N{U+1780}-\N{U+17FF}]/u;
$m{"Mongolian"} = qr/[\N{U+1800}-\N{U+18AF}]/u;
$m{"Unified Canadian Aboriginal Syllabics Extended"} = qr/[\N{U+18B0}-\N{U+18FF}]/u;
$m{"Limbu"} = qr/[\N{U+1900}-\N{U+194F}]/u;
$m{"Tai Le"} = qr/[\N{U+1950}-\N{U+197F}]/u;
$m{"New Tai Lue"} = qr/[\N{U+1980}-\N{U+19DF}]/u;
$m{"Khmer Symbols"} = qr/[\N{U+19E0}-\N{U+19FF}]/u;
$m{"Buginese"} = qr/[\N{U+1A00}-\N{U+1A1F}]/u;
$m{"Tai Tham"} = qr/[\N{U+1A20}-\N{U+1AAF}]/u;
$m{"Balinese"} = qr/[\N{U+1B00}-\N{U+1B7F}]/u;
$m{"Sundanese"} = qr/[\N{U+1B80}-\N{U+1BBF}]/u;
$m{"Batak"} = qr/[\N{U+1BC0}-\N{U+1BFF}]/u;
$m{"Lepcha"} = qr/[\N{U+1C00}-\N{U+1C4F}]/u;
$m{"Ol Chiki"} = qr/[\N{U+1C50}-\N{U+1C7F}]/u;
$m{"Sundanese Supplement"} = qr/[\N{U+1CC0}-\N{U+1CCF}]/u;
$m{"Vedic Extensions"} = qr/[\N{U+1CD0}-\N{U+1CFF}]/u;
$m{"Phonetic Extensions"} = qr/[\N{U+1D00}-\N{U+1D7F}]/u;
$m{"Phonetic Extensions Supplement"} = qr/[\N{U+1D80}-\N{U+1DBF}]/u;
$m{"Combining Diacritical Marks Supplement"} = qr/[\N{U+1DC0}-\N{U+1DFF}]/u;
$m{"Latin Extended Additional"} = qr/[\N{U+1E00}-\N{U+1EFF}]/u;
$m{"Greek Extended"} = qr/[\N{U+1F00}-\N{U+1FFF}]/u;
$m{"General Punctuation"} = qr/[\N{U+2000}-\N{U+206F}]/u;
$m{"Superscripts and Subscripts"} = qr/[\N{U+2070}-\N{U+209F}]/u;
$m{"Currency Symbols"} = qr/[\N{U+20A0}-\N{U+20CF}]/u;
$m{"Combining Diacritical Marks for Symbols"} = qr/[\N{U+20D0}-\N{U+20FF}]/u;
$m{"Letterlike Symbols"} = qr/[\N{U+2100}-\N{U+214F}]/u;
$m{"Number Forms"} = qr/[\N{U+2150}-\N{U+218F}]/u;
$m{"Arrows"} = qr/[\N{U+2190}-\N{U+21FF}]/u;
$m{"Mathematical Operators"} = qr/[\N{U+2200}-\N{U+22FF}]/u;
$m{"Miscellaneous Technical"} = qr/[\N{U+2300}-\N{U+23FF}]/u;
$m{"Control Pictures"} = qr/[\N{U+2400}-\N{U+243F}]/u;
$m{"Optical Character Recognition"} = qr/[\N{U+2440}-\N{U+245F}]/u;
$m{"Enclosed Alphanumerics"} = qr/[\N{U+2460}-\N{U+24FF}]/u;
$m{"Box Drawing"} = qr/[\N{U+2500}-\N{U+257F}]/u;
$m{"Block Elements"} = qr/[\N{U+2580}-\N{U+259F}]/u;
$m{"Geometric Shapes"} = qr/[\N{U+25A0}-\N{U+25FF}]/u;
$m{"Miscellaneous Symbols"} = qr/[\N{U+2600}-\N{U+26FF}]/u;
$m{"Dingbats"} = qr/[\N{U+2700}-\N{U+27BF}]/u;
$m{"Miscellaneous Mathematical Symbols-A"} = qr/[\N{U+27C0}-\N{U+27EF}]/u;
$m{"Supplemental Arrows-A"} = qr/[\N{U+27F0}-\N{U+27FF}]/u;
$m{"Braille Patterns"} = qr/[\N{U+2800}-\N{U+28FF}]/u;
$m{"Supplemental Arrows-B"} = qr/[\N{U+2900}-\N{U+297F}]/u;
$m{"Miscellaneous Mathematical Symbols-B"} = qr/[\N{U+2980}-\N{U+29FF}]/u;
$m{"Supplemental Mathematical Operators"} = qr/[\N{U+2A00}-\N{U+2AFF}]/u;
$m{"Miscellaneous Symbols and Arrows"} = qr/[\N{U+2B00}-\N{U+2BFF}]/u;
$m{"Glagolitic"} = qr/[\N{U+2C00}-\N{U+2C5F}]/u;
$m{"Latin Extended-C"} = qr/[\N{U+2C60}-\N{U+2C7F}]/u;
$m{"Coptic"} = qr/[\N{U+2C80}-\N{U+2CFF}]/u;
$m{"Georgian Supplement"} = qr/[\N{U+2D00}-\N{U+2D2F}]/u;
$m{"Tifinagh"} = qr/[\N{U+2D30}-\N{U+2D7F}]/u;
$m{"Ethiopic Extended"} = qr/[\N{U+2D80}-\N{U+2DDF}]/u;
$m{"Cyrillic Extended-A"} = qr/[\N{U+2DE0}-\N{U+2DFF}]/u;
$m{"Supplemental Punctuation"} = qr/[\N{U+2E00}-\N{U+2E7F}]/u;
$m{"CJK Radicals Supplement"} = qr/[\N{U+2E80}-\N{U+2EFF}]/u;
$m{"Kangxi Radicals"} = qr/[\N{U+2F00}-\N{U+2FDF}]/u;
$m{"Ideographic Description Characters"} = qr/[\N{U+2FF0}-\N{U+2FFF}]/u;
$m{"CJK Symbols and Punctuation"} = qr/[\N{U+3000}-\N{U+303F}]/u;
$m{"Hiragana"} = qr/[\N{U+3040}-\N{U+309F}]/u;
$m{"Katakana"} = qr/[\N{U+30A0}-\N{U+30FF}]/u;
$m{"Bopomofo"} = qr/[\N{U+3100}-\N{U+312F}]/u;
$m{"Hangul Compatibility Jamo"} = qr/[\N{U+3130}-\N{U+318F}]/u;
$m{"Kanbun"} = qr/[\N{U+3190}-\N{U+319F}]/u;
$m{"Bopomofo Extended"} = qr/[\N{U+31A0}-\N{U+31BF}]/u;
$m{"CJK Strokes"} = qr/[\N{U+31C0}-\N{U+31EF}]/u;
$m{"Katakana Phonetic Extensions"} = qr/[\N{U+31F0}-\N{U+31FF}]/u;
$m{"Enclosed CJK Letters and Months"} = qr/[\N{U+3200}-\N{U+32FF}]/u;
$m{"CJK Compatibility"} = qr/[\N{U+3300}-\N{U+33FF}]/u;
$m{"CJK Unified Ideographs Extension A"} = qr/[\N{U+3400}-\N{U+4DBF}]/u;
$m{"Yijing Hexagram Symbols"} = qr/[\N{U+4DC0}-\N{U+4DFF}]/u;
$m{"CJK Unified Ideographs"} = qr/[\N{U+4E00}-\N{U+9FFF}]/u;
$m{"Yi Syllables"} = qr/[\N{U+A000}-\N{U+A48F}]/u;
$m{"Yi Radicals"} = qr/[\N{U+A490}-\N{U+A4CF}]/u;
$m{"Lisu"} = qr/[\N{U+A4D0}-\N{U+A4FF}]/u;
$m{"Vai"} = qr/[\N{U+A500}-\N{U+A63F}]/u;
$m{"Cyrillic Extended-B"} = qr/[\N{U+A640}-\N{U+A69F}]/u;
$m{"Bamum"} = qr/[\N{U+A6A0}-\N{U+A6FF}]/u;
$m{"Modifier Tone Letters"} = qr/[\N{U+A700}-\N{U+A71F}]/u;
$m{"Latin Extended-D"} = qr/[\N{U+A720}-\N{U+A7FF}]/u;
$m{"Syloti Nagri"} = qr/[\N{U+A800}-\N{U+A82F}]/u;
$m{"Common Indic Number Forms"} = qr/[\N{U+A830}-\N{U+A83F}]/u;
$m{"Phags-pa"} = qr/[\N{U+A840}-\N{U+A87F}]/u;
$m{"Saurashtra"} = qr/[\N{U+A880}-\N{U+A8DF}]/u;
$m{"Devanagari Extended"} = qr/[\N{U+A8E0}-\N{U+A8FF}]/u;
$m{"Kayah Li"} = qr/[\N{U+A900}-\N{U+A92F}]/u;
$m{"Rejang"} = qr/[\N{U+A930}-\N{U+A95F}]/u;
$m{"Hangul Jamo Extended-A"} = qr/[\N{U+A960}-\N{U+A97F}]/u;
$m{"Javanese"} = qr/[\N{U+A980}-\N{U+A9DF}]/u;
$m{"Cham"} = qr/[\N{U+AA00}-\N{U+AA5F}]/u;
$m{"Myanmar Extended-A"} = qr/[\N{U+AA60}-\N{U+AA7F}]/u;
$m{"Tai Viet"} = qr/[\N{U+AA80}-\N{U+AADF}]/u;
$m{"Meetei Mayek Extensions"} = qr/[\N{U+AAE0}-\N{U+AAFF}]/u;
$m{"Ethiopic Extended-A"} = qr/[\N{U+AB00}-\N{U+AB2F}]/u;
$m{"Meetei Mayek"} = qr/[\N{U+ABC0}-\N{U+ABFF}]/u;
$m{"Hangul Syllables"} = qr/[\N{U+AC00}-\N{U+D7AF}]/u;
$m{"Hangul Jamo Extended-B"} = qr/[\N{U+D7B0}-\N{U+D7FF}]/u;
$m{"High Surrogates"} = qr/[\N{U+D800}-\N{U+DB7F}]/u;
$m{"High Private Use Surrogates"} = qr/[\N{U+DB80}-\N{U+DBFF}]/u;
$m{"Low Surrogates"} = qr/[\N{U+DC00}-\N{U+DFFF}]/u;
$m{"Private Use Area"} = qr/[\N{U+E000}-\N{U+F8FF}]/u;
$m{"CJK Compatibility Ideographs"} = qr/[\N{U+F900}-\N{U+FAFF}]/u;
$m{"Alphabetic Presentation Forms"} = qr/[\N{U+FB00}-\N{U+FB4F}]/u;
$m{"Arabic Presentation Forms-A"} = qr/[\N{U+FB50}-\N{U+FDFF}]/u;
$m{"Variation Selectors"} = qr/[\N{U+FE00}-\N{U+FE0F}]/u;
$m{"Vertical Forms"} = qr/[\N{U+FE10}-\N{U+FE1F}]/u;
$m{"Combining Half Marks"} = qr/[\N{U+FE20}-\N{U+FE2F}]/u;
$m{"CJK Compatibility Forms"} = qr/[\N{U+FE30}-\N{U+FE4F}]/u;
$m{"Small Form Variants"} = qr/[\N{U+FE50}-\N{U+FE6F}]/u;
$m{"Arabic Presentation Forms-B"} = qr/[\N{U+FE70}-\N{U+FEFF}]/u;
$m{"Halfwidth and Fullwidth Forms"} = qr/[\N{U+FF00}-\N{U+FFEF}]/u;
$m{"Specials"} = qr/[\N{U+FFF0}-\N{U+FFFF}]/u;
$m{"Linear B Syllabary"} = qr/[\N{U+10000}-\N{U+1007F}]/u;
$m{"Linear B Ideograms"} = qr/[\N{U+10080}-\N{U+100FF}]/u;
$m{"Aegean Numbers"} = qr/[\N{U+10100}-\N{U+1013F}]/u;
$m{"Ancient Greek Numbers"} = qr/[\N{U+10140}-\N{U+1018F}]/u;
$m{"Ancient Symbols"} = qr/[\N{U+10190}-\N{U+101CF}]/u;
$m{"Phaistos Disc"} = qr/[\N{U+101D0}-\N{U+101FF}]/u;
$m{"Lycian"} = qr/[\N{U+10280}-\N{U+1029F}]/u;
$m{"Carian"} = qr/[\N{U+102A0}-\N{U+102DF}]/u;
$m{"Old Italic"} = qr/[\N{U+10300}-\N{U+1032F}]/u;
$m{"Gothic"} = qr/[\N{U+10330}-\N{U+1034F}]/u;
$m{"Ugaritic"} = qr/[\N{U+10380}-\N{U+1039F}]/u;
$m{"Old Persian"} = qr/[\N{U+103A0}-\N{U+103DF}]/u;
$m{"Deseret"} = qr/[\N{U+10400}-\N{U+1044F}]/u;
$m{"Shavian"} = qr/[\N{U+10450}-\N{U+1047F}]/u;
$m{"Osmanya"} = qr/[\N{U+10480}-\N{U+104AF}]/u;
$m{"Cypriot Syllabary"} = qr/[\N{U+10800}-\N{U+1083F}]/u;
$m{"Imperial Aramaic"} = qr/[\N{U+10840}-\N{U+1085F}]/u;
$m{"Phoenician"} = qr/[\N{U+10900}-\N{U+1091F}]/u;
$m{"Lydian"} = qr/[\N{U+10920}-\N{U+1093F}]/u;
$m{"Meroitic Hieroglyphs"} = qr/[\N{U+10980}-\N{U+1099F}]/u;
$m{"Meroitic Cursive"} = qr/[\N{U+109A0}-\N{U+109FF}]/u;
$m{"Kharoshthi"} = qr/[\N{U+10A00}-\N{U+10A5F}]/u;
$m{"Old South Arabian"} = qr/[\N{U+10A60}-\N{U+10A7F}]/u;
$m{"Avestan"} = qr/[\N{U+10B00}-\N{U+10B3F}]/u;
$m{"Inscriptional Parthian"} = qr/[\N{U+10B40}-\N{U+10B5F}]/u;
$m{"Inscriptional Pahlavi"} = qr/[\N{U+10B60}-\N{U+10B7F}]/u;
$m{"Old Turkic"} = qr/[\N{U+10C00}-\N{U+10C4F}]/u;
$m{"Rumi Numeral Symbols"} = qr/[\N{U+10E60}-\N{U+10E7F}]/u;
$m{"Brahmi"} = qr/[\N{U+11000}-\N{U+1107F}]/u;
$m{"Kaithi"} = qr/[\N{U+11080}-\N{U+110CF}]/u;
$m{"Sora Sompeng"} = qr/[\N{U+110D0}-\N{U+110FF}]/u;
$m{"Chakma"} = qr/[\N{U+11100}-\N{U+1114F}]/u;
$m{"Sharada"} = qr/[\N{U+11180}-\N{U+111DF}]/u;
$m{"Takri"} = qr/[\N{U+11680}-\N{U+116CF}]/u;
$m{"Cuneiform"} = qr/[\N{U+12000}-\N{U+123FF}]/u;
$m{"Cuneiform Numbers and Punctuation"} = qr/[\N{U+12400}-\N{U+1247F}]/u;
$m{"Egyptian Hieroglyphs"} = qr/[\N{U+13000}-\N{U+1342F}]/u;
$m{"Bamum Supplement"} = qr/[\N{U+16800}-\N{U+16A3F}]/u;
$m{"Miao"} = qr/[\N{U+16F00}-\N{U+16F9F}]/u;
$m{"Kana Supplement"} = qr/[\N{U+1B000}-\N{U+1B0FF}]/u;
$m{"Byzantine Musical Symbols"} = qr/[\N{U+1D000}-\N{U+1D0FF}]/u;
$m{"Musical Symbols"} = qr/[\N{U+1D100}-\N{U+1D1FF}]/u;
$m{"Ancient Greek Musical Notation"} = qr/[\N{U+1D200}-\N{U+1D24F}]/u;
$m{"Tai Xuan Jing Symbols"} = qr/[\N{U+1D300}-\N{U+1D35F}]/u;
$m{"Counting Rod Numerals"} = qr/[\N{U+1D360}-\N{U+1D37F}]/u;
$m{"Mathematical Alphanumeric Symbols"} = qr/[\N{U+1D400}-\N{U+1D7FF}]/u;
$m{"Arabic Mathematical Alphabetic Symbols"} = qr/[\N{U+1EE00}-\N{U+1EEFF}]/u;
$m{"Mahjong Tiles"} = qr/[\N{U+1F000}-\N{U+1F02F}]/u;
$m{"Domino Tiles"} = qr/[\N{U+1F030}-\N{U+1F09F}]/u;
$m{"Playing Cards"} = qr/[\N{U+1F0A0}-\N{U+1F0FF}]/u;
$m{"Enclosed Alphanumeric Supplement"} = qr/[\N{U+1F100}-\N{U+1F1FF}]/u;
$m{"Enclosed Ideographic Supplement"} = qr/[\N{U+1F200}-\N{U+1F2FF}]/u;
$m{"Miscellaneous Symbols And Pictographs"} = qr/[\N{U+1F300}-\N{U+1F5FF}]/u;
$m{"Emoticons"} = qr/[\N{U+1F600}-\N{U+1F64F}]/u;
$m{"Transport And Map Symbols"} = qr/[\N{U+1F680}-\N{U+1F6FF}]/u;
$m{"Alchemical Symbols"} = qr/[\N{U+1F700}-\N{U+1F77F}]/u;
$m{"CJK Unified Ideographs Extension B"} = qr/[\N{U+20000}-\N{U+2A6DF}]/u;
$m{"CJK Unified Ideographs Extension C"} = qr/[\N{U+2A700}-\N{U+2B73F}]/u;
$m{"CJK Unified Ideographs Extension D"} = qr/[\N{U+2B740}-\N{U+2B81F}]/u;
$m{"CJK Compatibility Ideographs Supplement"} = qr/[\N{U+2F800}-\N{U+2FA1F}]/u;
$m{"Tags"} = qr/[\N{U+E0000}-\N{U+E007F}]/u;
$m{"Variation Selectors Supplement"} = qr/[\N{U+E0100}-\N{U+E01EF}]/u;
$m{"Supplementary Private Use Area-A"} = qr/[\N{U+F0000}-\N{U+FFFFF}]/u;
$m{"Supplementary Private Use Area-B"} = qr/[\N{U+100000}-\N{U+10FFFF}]/u;

my %global_matches;

LINE: while (<STDIN>) {
	my $line = $_;
	chomp( $line);
	my $match_names = "";

	foreach my $name ( keys %m) {
		my $match = $m{$name};
		if ( $line =~ m/$match/u) {
			$match_names .= "'$name' ";
			$global_matches{$name} = 1;
		}
	}
	print "$line\nUnicode blocks found: $match_names\n";
}


#
## Blocks-6.3.0.txt
## Date: 2012-12-02, 09:45:00 GMT [KW, LI]
##
## Unicode Character Database
## Copyright (c) 1991-2012 Unicode, Inc.
## For terms of use, see http://www.unicode.org/terms_of_use.html
## For documentation, see http://www.unicode.org/reports/tr44/
##
## Note:   The casing of block names is not normative.
##         For example, "Basic Latin" and "BASIC LATIN" are equivalent.
##
## Format:
## Start Code..End Code; Block Name
#
## ================================================
#
## Note:   When comparing block names, casing, whitespace, hyphens,
##         and underbars are ignored.
##         For example, "Latin Extended-A" and "latin extended a" are equivalent.
##         For more information on the comparison of property values, 
##            see UAX #44: http://www.unicode.org/reports/tr44/
##
##  All code points not explicitly listed for Block
##  have the value No_Block.
#
## Property:	Block
##
## @missing: 0000..10FFFF; No_Block
#
#0000..007F; Basic Latin
#0080..00FF; Latin-1 Supplement
#0100..017F; Latin Extended-A
#0180..024F; Latin Extended-B
#0250..02AF; IPA Extensions
#02B0..02FF; Spacing Modifier Letters
#0300..036F; Combining Diacritical Marks
#0370..03FF; Greek and Coptic
#0400..04FF; Cyrillic
#0500..052F; Cyrillic Supplement
#0530..058F; Armenian
#0590..05FF; Hebrew
#0600..06FF; Arabic
#0700..074F; Syriac
#0750..077F; Arabic Supplement
#0780..07BF; Thaana
#07C0..07FF; NKo
#0800..083F; Samaritan
#0840..085F; Mandaic
#08A0..08FF; Arabic Extended-A
#0900..097F; Devanagari
#0980..09FF; Bengali
#0A00..0A7F; Gurmukhi
#0A80..0AFF; Gujarati
#0B00..0B7F; Oriya
#0B80..0BFF; Tamil
#0C00..0C7F; Telugu
#0C80..0CFF; Kannada
#0D00..0D7F; Malayalam
#0D80..0DFF; Sinhala
#0E00..0E7F; Thai
#0E80..0EFF; Lao
#0F00..0FFF; Tibetan
#1000..109F; Myanmar
#10A0..10FF; Georgian
#1100..11FF; Hangul Jamo
#1200..137F; Ethiopic
#1380..139F; Ethiopic Supplement
#13A0..13FF; Cherokee
#1400..167F; Unified Canadian Aboriginal Syllabics
#1680..169F; Ogham
#16A0..16FF; Runic
#1700..171F; Tagalog
#1720..173F; Hanunoo
#1740..175F; Buhid
#1760..177F; Tagbanwa
#1780..17FF; Khmer
#1800..18AF; Mongolian
#18B0..18FF; Unified Canadian Aboriginal Syllabics Extended
#1900..194F; Limbu
#1950..197F; Tai Le
#1980..19DF; New Tai Lue
#19E0..19FF; Khmer Symbols
#1A00..1A1F; Buginese
#1A20..1AAF; Tai Tham
#1B00..1B7F; Balinese
#1B80..1BBF; Sundanese
#1BC0..1BFF; Batak
#1C00..1C4F; Lepcha
#1C50..1C7F; Ol Chiki
#1CC0..1CCF; Sundanese Supplement
#1CD0..1CFF; Vedic Extensions
#1D00..1D7F; Phonetic Extensions
#1D80..1DBF; Phonetic Extensions Supplement
#1DC0..1DFF; Combining Diacritical Marks Supplement
#1E00..1EFF; Latin Extended Additional
#1F00..1FFF; Greek Extended
#2000..206F; General Punctuation
#2070..209F; Superscripts and Subscripts
#20A0..20CF; Currency Symbols
#20D0..20FF; Combining Diacritical Marks for Symbols
#2100..214F; Letterlike Symbols
#2150..218F; Number Forms
#2190..21FF; Arrows
#2200..22FF; Mathematical Operators
#2300..23FF; Miscellaneous Technical
#2400..243F; Control Pictures
#2440..245F; Optical Character Recognition
#2460..24FF; Enclosed Alphanumerics
#2500..257F; Box Drawing
#2580..259F; Block Elements
#25A0..25FF; Geometric Shapes
#2600..26FF; Miscellaneous Symbols
#2700..27BF; Dingbats
#27C0..27EF; Miscellaneous Mathematical Symbols-A
#27F0..27FF; Supplemental Arrows-A
#2800..28FF; Braille Patterns
#2900..297F; Supplemental Arrows-B
#2980..29FF; Miscellaneous Mathematical Symbols-B
#2A00..2AFF; Supplemental Mathematical Operators
#2B00..2BFF; Miscellaneous Symbols and Arrows
#2C00..2C5F; Glagolitic
#2C60..2C7F; Latin Extended-C
#2C80..2CFF; Coptic
#2D00..2D2F; Georgian Supplement
#2D30..2D7F; Tifinagh
#2D80..2DDF; Ethiopic Extended
#2DE0..2DFF; Cyrillic Extended-A
#2E00..2E7F; Supplemental Punctuation
#2E80..2EFF; CJK Radicals Supplement
#2F00..2FDF; Kangxi Radicals
#2FF0..2FFF; Ideographic Description Characters
#3000..303F; CJK Symbols and Punctuation
#3040..309F; Hiragana
#30A0..30FF; Katakana
#3100..312F; Bopomofo
#3130..318F; Hangul Compatibility Jamo
#3190..319F; Kanbun
#31A0..31BF; Bopomofo Extended
#31C0..31EF; CJK Strokes
#31F0..31FF; Katakana Phonetic Extensions
#3200..32FF; Enclosed CJK Letters and Months
#3300..33FF; CJK Compatibility
#3400..4DBF; CJK Unified Ideographs Extension A
#4DC0..4DFF; Yijing Hexagram Symbols
#4E00..9FFF; CJK Unified Ideographs
#A000..A48F; Yi Syllables
#A490..A4CF; Yi Radicals
#A4D0..A4FF; Lisu
#A500..A63F; Vai
#A640..A69F; Cyrillic Extended-B
#A6A0..A6FF; Bamum
#A700..A71F; Modifier Tone Letters
#A720..A7FF; Latin Extended-D
#A800..A82F; Syloti Nagri
#A830..A83F; Common Indic Number Forms
#A840..A87F; Phags-pa
#A880..A8DF; Saurashtra
#A8E0..A8FF; Devanagari Extended
#A900..A92F; Kayah Li
#A930..A95F; Rejang
#A960..A97F; Hangul Jamo Extended-A
#A980..A9DF; Javanese
#AA00..AA5F; Cham
#AA60..AA7F; Myanmar Extended-A
#AA80..AADF; Tai Viet
#AAE0..AAFF; Meetei Mayek Extensions
#AB00..AB2F; Ethiopic Extended-A
#ABC0..ABFF; Meetei Mayek
#AC00..D7AF; Hangul Syllables
#D7B0..D7FF; Hangul Jamo Extended-B
#D800..DB7F; High Surrogates
#DB80..DBFF; High Private Use Surrogates
#DC00..DFFF; Low Surrogates
#E000..F8FF; Private Use Area
#F900..FAFF; CJK Compatibility Ideographs
#FB00..FB4F; Alphabetic Presentation Forms
#FB50..FDFF; Arabic Presentation Forms-A
#FE00..FE0F; Variation Selectors
#FE10..FE1F; Vertical Forms
#FE20..FE2F; Combining Half Marks
#FE30..FE4F; CJK Compatibility Forms
#FE50..FE6F; Small Form Variants
#FE70..FEFF; Arabic Presentation Forms-B
#FF00..FFEF; Halfwidth and Fullwidth Forms
#FFF0..FFFF; Specials
#10000..1007F; Linear B Syllabary
#10080..100FF; Linear B Ideograms
#10100..1013F; Aegean Numbers
#10140..1018F; Ancient Greek Numbers
#10190..101CF; Ancient Symbols
#101D0..101FF; Phaistos Disc
#10280..1029F; Lycian
#102A0..102DF; Carian
#10300..1032F; Old Italic
#10330..1034F; Gothic
#10380..1039F; Ugaritic
#103A0..103DF; Old Persian
#10400..1044F; Deseret
#10450..1047F; Shavian
#10480..104AF; Osmanya
#10800..1083F; Cypriot Syllabary
#10840..1085F; Imperial Aramaic
#10900..1091F; Phoenician
#10920..1093F; Lydian
#10980..1099F; Meroitic Hieroglyphs
#109A0..109FF; Meroitic Cursive
#10A00..10A5F; Kharoshthi
#10A60..10A7F; Old South Arabian
#10B00..10B3F; Avestan
#10B40..10B5F; Inscriptional Parthian
#10B60..10B7F; Inscriptional Pahlavi
#10C00..10C4F; Old Turkic
#10E60..10E7F; Rumi Numeral Symbols
#11000..1107F; Brahmi
#11080..110CF; Kaithi
#110D0..110FF; Sora Sompeng
#11100..1114F; Chakma
#11180..111DF; Sharada
#11680..116CF; Takri
#12000..123FF; Cuneiform
#12400..1247F; Cuneiform Numbers and Punctuation
#13000..1342F; Egyptian Hieroglyphs
#16800..16A3F; Bamum Supplement
#16F00..16F9F; Miao
#1B000..1B0FF; Kana Supplement
#1D000..1D0FF; Byzantine Musical Symbols
#1D100..1D1FF; Musical Symbols
#1D200..1D24F; Ancient Greek Musical Notation
#1D300..1D35F; Tai Xuan Jing Symbols
#1D360..1D37F; Counting Rod Numerals
#1D400..1D7FF; Mathematical Alphanumeric Symbols
#1EE00..1EEFF; Arabic Mathematical Alphabetic Symbols
#1F000..1F02F; Mahjong Tiles
#1F030..1F09F; Domino Tiles
#1F0A0..1F0FF; Playing Cards
#1F100..1F1FF; Enclosed Alphanumeric Supplement
#1F200..1F2FF; Enclosed Ideographic Supplement
#1F300..1F5FF; Miscellaneous Symbols And Pictographs
#1F600..1F64F; Emoticons
#1F680..1F6FF; Transport And Map Symbols
#1F700..1F77F; Alchemical Symbols
#20000..2A6DF; CJK Unified Ideographs Extension B
#2A700..2B73F; CJK Unified Ideographs Extension C
#2B740..2B81F; CJK Unified Ideographs Extension D
#2F800..2FA1F; CJK Compatibility Ideographs Supplement
#E0000..E007F; Tags
#E0100..E01EF; Variation Selectors Supplement
#F0000..FFFFF; Supplementary Private Use Area-A
#100000..10FFFF; Supplementary Private Use Area-B
