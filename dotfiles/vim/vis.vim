" vis.vim:
" Function: Perform an Ex command on a visual highlighted block (CTRL-V).
"
" Requires: Requires 6.0 or later  (this script is a plugin)
"
" Usage:    Mark visual block (CTRL-V) or visual character (v),
"           press ':B ' and enter an Ex command [cmd].
"
"           ex. Use ctrl-v to visually mark the block then use
"                 :B cmd     (will appear as   :'<,'>B cmd )
"
"           ex. Use v to visually mark the block then use
"                 :B cmd     (will appear as   :'<,'>B cmd )
"
"           Command-line completion is supported for Ex commands.
"
" Note:     There must be a space before the '!' when invoking external shell
"           commands, eg. ':B !sort'. Otherwise an error is reported.
"
"           Doesn't work as one might expect with Vim's ve option.  That's
"           because ve=all ended up leaving unwanted blank columns, so the
"           solution chosen was to have the vis function turn ve off temporarily.
"
" Author:   Charles E. Campbell <cec@NdjOinnSi.gPsfAc.nMasa.gov>, remove NOSPAM first
"           Based on idea of Stefan Roemer <roemer@informatik.tu-muenchen.de>
"
" Version:  11
"
" History:
"   11 : Jun 13, 2003 - bugfix (visual-mode cleared just before executing
"                               desired command on selected text)
"   10 : Feb 11, 2003 - bugfix (ignorecase option interfered with v)
"    9 : Sep 10, 2002 - bugfix (left Decho on, now commented out)
"    8 : Sep 09, 2002 - bugfix (first column problem)
"    7 : Sep 05, 2002 - bugfix (was forcing begcol<endcol for "v" mode)
"    6 : Jun 25, 2002 - bugfix (VirtcolM1 instead of virtcol()-1)
"    5 : Jun 21, 2002 - now supports character-visual mode (v) and
"                       linewise-visual mode (V)
"    4 : Jun 20, 2002 - saves sol, sets nosol, restores sol
"                     - bugfix: 0 inserted: 0\<c-v>G$\"ad
"                     - Fixed double-loading (was commented
"                       out for debugging purposes)
"    3 : Jun 20, 2002 - saves ve, unsets ve, restores ve
"    2 : Jun 19, 2002 - Charles Campbell's <vis.vim>
"    1 : epoch        - Stefan Roemer's    <vis.vim>
" ------------------------------------------------------------------------------

" Exit quickly when <Vis.vim> has already been loaded or when 'compatible' is set
if exists("loaded_visvim") || &cp
  finish
endif
let loaded_visvim= 1

" ------------------------------------------------------------------------------

"  -range       : VisBlockCmd operates on the range itself
"  -com=command : Ex command and arguments
"  -nargs=+     : arguments may be supplied, up to any quantity
com! -range -nargs=+ -com=command B <line1>,<line2>call s:VisBlockCmd('<args>')

" ------------------------------------------------------------------------------

" VisBlockCmd:
fu! <SID>VisBlockCmd(cmd) range

  " retain and re-use same visual mode
  let vmode= visualmode()

  " save options which otherwise may interfere
  let keep_lz    = &lz
  let keep_sol   = &sol
  let keep_ve    = &ve
  let keep_ww    = &ww
  let keep_ic    = &ic
  let keep_magic = &magic
  let keep_line  = line(".")
  let keep_col   = virtcol(".")
  norm! H0
  let keep_hline = line(".")
  set lz
  set nosol
  set ve=
  set ww=
  set noic
  set magic

  " Save any contents in register a
  let rega= @a

  if vmode == 'V'
   exe "'<,'>".a:cmd
  else

   " Initialize so begcol<endcol for non-v modes
   let begcol   = s:VirtcolM1("'<")
   let endcol   = s:VirtcolM1("'>")
   if vmode != 'v'
    if begcol > endcol
     let begcol  = s:VirtcolM1("'>")
     let endcol  = s:VirtcolM1("'<")
    endif
   endif

   " Initialize so that begline<endline
   let begline  = a:firstline
   let endline  = a:lastline
   if begline > endline
    let begline = a:lastline
    let endline = a:firstline
   endif
"  call Decho('beg['.begline.','.begcol.'] end['.endline.','.endcol.']')

   " Modify Selected Region:
   " =======================
   " delete selected region into register "a
   " put cut-out text at end-of-file
   " apply command to those lines
   " visual-block select the modified text in those lines
   " delete excess lines
   " put modified text back into file
   norm! gv"ad
   $
   pu_
   let lastline= line("$")
   silent norm! "ap
   call visualmode("0")
   exe '.,$'.a:cmd
   exe lastline
   exe "norm! 0".vmode."G$\"ad"
   silent exe lastline.',$d'
   exe begline
   if begcol > 1
    exe 'norm! '.begcol."\<bar>\"ap"
   elseif begcol == 1
    norm! 0"ap
   else
    norm! 0"aP
   endif

   " attempt to restore gv -- this is limited, it will
   " select the same size region in the same place as before,
   " not necessarily the changed region
   let begcol= begcol+1
   let endcol= endcol+1
   silent exe begline
   silent exe 'norm! '.begcol."\<bar>".vmode
   silent exe endline
   silent exe 'norm! '.endcol."\<bar>\<esc>"
   silent exe begline
   silent exe 'norm! '.begcol."\<bar>"

   " attempt to restore screen position
  exe "silent! norm! ".keep_hline."G0z\<CR>"
  exe "silent! norm! ".keep_line."G0".keep_col."\<bar>"
  endif

  " restore register a and options
  let @a  = rega
  let &lz = keep_lz
  let &sol= keep_sol
  let &ve = keep_ve
  let &ww = keep_ww
  let &ic = keep_ic

endfunction

" ------------------------------------------------------------------------------

" VirtcolM1: usually a virtcol(mark)-1, but due to tabs this can be different
fu! s:VirtcolM1(mark)
  if virtcol(a:mark) <= 1
   return 0
  endif
  exe "norm! `".strpart(a:mark,1)."h"
  return virtcol(".")
endfunction

" ------------------------------------------------------------------------------
