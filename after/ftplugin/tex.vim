" spell
set spelllang=en_us spell
set spellfile=$HOME/.vim/plugged/vimide/spell/dict.utf-8.add

hi clear SpellBad
hi SpellBad cterm=underline


" mapping '§' to reformat selected code in latex
:map <silent> § :call IndentComments("%") <CR>
autocmd FileType tex set foldlevelstart=99

:set wrap
:ALEDisable



if has('gui_running')
    imap <buffer> <silent> <F9> <Plug>Tex_Completion
else
    imap <buffer> <F9> <Plug>Tex_Completion
endif


" " vim-latex
" set nocompatible
" set grepprg=grep\ -nH\ $*
" let g:tex_flavor='latex'
" let g:Tex_DefaultTargetFormat = 'pdf'
" let g:Tex_CompileRule_pdf = 'latexmk -pdf -pdflatex="pdflatex -synctex=1 -interaction=nonstopmode --shell-escape" -f $*; latexmk -c'
" set iskeyword+=:

" vimtex
let g:vimtex_view_general_viewer = 'okular'
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
let g:tex_flavor = 'latex'
let g:vimtex_compiler_latexmk = {
      \ 'options' : [
      \   '-bibtex',
      \   '-shell-escape',
      \   '-file-line-error',
      \   '-verbose',
      \   '-synctex=1',
      \   '-interaction=nonstopmode',
      \ ],
      \}

let g:vimtex_quickfix_ignore_filters = [
      \ 'Underfull',
      \ 'Overfull',
      \ 'Font',
      \ 'Float',
      \ 'Difference',
      \]

let g:vimtex_quickfix_mode = 0
