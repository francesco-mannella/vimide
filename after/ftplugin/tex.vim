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
