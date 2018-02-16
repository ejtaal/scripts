#        1         2         3         4         5
#2345678901234567890123456789012345678901234567890123456789
# HTML COLOR         COL A N T STRING or REGULAR EXPRESSION
#################### ### # # # ############################
#Where:
#  HTML COLOR - Standard HTML Color name for HTML output
#  COL        - Console color name from the list
#                 red, yel, cya, grn, mag, blk, whi, blu
#  A          - Attribute from the list
#                 ' ' : normal
#                 'b' : bold
#                 'u' : underline
#                 'r' : reverse video
#                 'k' : blink
#  N          - number of matches
#                 ' ' : all
#                 '0' : all
#                 '1' - '9' : number of matches
#  T          - type of matching to perform
#                 'c' : characters
#                 's' : string
#                 'r' : regex
#                 't' : regex with Unix time conversion
#                 ' ' : default (regex)
#        1         2         3         4         5
#2345678901234567890123456789012345678901234567890123456789
# HTML COLOR         COL A N T STRING or REGULAR EXPRESSION
#################### ### # # # ############################
                     yel b   r (^==.*$)
                     grn b   r (^.*crypt.*$)
                     grn b   r ^[1-9]:\s*(.*?):.*UP
                     yel     r ^[1-9]:\s*(.*?):.*DOWN
                     grn b   r ^0.0.0.0\s*([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)
                     red b   r ^(├|└)(.*part /.*)$
                     yel b   r ^(.*\s:\s##.* )(\?\?|A|M)(\s.*$)
                     yel b   r ^(.*\s\[ahead [0-9]+\])
                     grn b   r ^(.*## master...origin/master)$
#                     yel b   r \s:\s*(A\s.*$)
#                     red b   r (0.0.0.0)
