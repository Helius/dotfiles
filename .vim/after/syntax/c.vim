" Vim filetype plugin file
" Language:    C file syntax extensions
" Maintainer:  Luinnar
" Last Change: 26 April 2010

" Common
syn match    Delimiter "[[\](){},;:?]"
syn match    Operator "[!&]"
syn match    Operator "[*+]"
syn match    Operator "[-%]"
syn match    Operator "\."
syn match    Operator "="
syn match    Operator "<"
syn match    Operator ">"
syn match    Operator "|"
syn match    Operator "\^"
syn match    Operator "\~"
" Define operator / so that it wouldn't overlap definition of /* // and /=
syn match    Operator "/[^*/=]"me=e-1
syn match    Operator "/$"

syn keyword  Constant TRUE FALSE

" Functions
syn match cUserFunction "\<\h\w*\>\(\s\|\n\)*("me=e-1
syn match cUserFunctionPointer "(\s*\*\s*\h\w*\s*)\(\s\|\n\)*(" contains=Delimiter,Operator

if filereadable( '.syntax.vim' ) | exec 'so .syntax.vim' | endif

syn match   myCMacro    "\<[A-Z_][A-Z_0-9]*\>"
syn keyword myCMacro    NULL

" Links
hi def link myCMacro              Macro
hi def link cUserFunction         Function
hi def link cUserFunctionPointer  Function
