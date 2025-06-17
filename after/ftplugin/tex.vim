" spell
set spelllang=en_us spell
set spellfile=$HOME/.vim/plugged/vimide/spell/dict.utf-8.add

hi clear SpellBad
hi SpellBad cterm=underline

" vim-latex
set nocompatible
set grepprg=grep\ -nH\ $*
let g:tex_flavor='latex'
let g:Tex_CompileRule_pdf = 'latexmk -pdf -pdflatex="pdflatex --shell-escape" -f $*; latexmk -c'
let g:Tex_FormatDependency_pdf = '.tex -> .pdf'
let g:Tex_UseMakefile = "0"
set iskeyword+=:

" mapping '§' to reformat selected code in latex
:map <silent> § :call IndentComments("%") <CR>
autocmd FileType tex set foldlevelstart=99

:set wrap
:ALEDisable
