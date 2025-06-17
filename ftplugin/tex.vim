" spell
set spelllang=en_gb spell
set spellfile=$HOME/Dropbox/vim/spell/en.utf-8.add

hi clear SpellBad
hi SpellBad cterm=underline

" vim-latex
set nocompatible
set grepprg=grep\ -nH\ $*
let g:tex_flavor='latex'
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_CompileRule_pdf = 'latexmk -pdf -pdflatex="pdflatex --shell-escape" -f $*; latexmk -c'
set iskeyword+=:

" mapping '§' to reformat selected code in latex
:map <silent> § :call IndentComments("%") <CR>
autocmd FileType tex set foldlevelstart=99

:set wrap
