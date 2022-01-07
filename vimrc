set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'vim-latex/vim-latex'
Plugin 'davidhalter/jedi-vim'
Plugin 'xavierd/clang_complete'
Plugin 'majutsushi/tagbar'
Plugin 'francesco-mannella/vimide'
Plugin 'python-rope/ropevim'
Plugin 'goerz/ipynb_notedown.vim'
Plugin 'tpope/vim-fugitive'



" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
filetype plugin on
let g:tex_flavor='latex'

"jedi-vim
let g:jedi#popup_select_first = 0
autocmd FileType python setlocal completeopt-=preview
let g:pymode_rope = 0

map <silent> <Up> gk
imap <silent> <Up> <C-o>gk
map <silent> <Down> gj
imap <silent> <Down> <C-o>gj
map <silent> <home> g<home>
imap <silent> <home> <C-o>g<home>
map <silent> <End> g<End>
imap <silent> <End> <C-o>g<End>

vnoremap <C-X> "+d
vnoremap <C-C> "+y
nnoremap <C-V> "+gPl
se nospell

setlocal linebreak
setlocal nolist
setlocal display+=lastline

au FocusLost * silent! wa

:set hidden
:set backspace=indent,eol,start
:set nowrap
:set lbr
:set number
:set noswf
:syntax enable
:set bs=2
:set nobk
:set smarttab
:set tabstop=4
:set softtabstop=4
:set shiftwidth=4
:set expandtab
:set shiftround
:set showmatch
:set ignorecase
:set smartcase
:set title
:syntax on
:filetype plugin indent on
:autocmd filetype python set expandtab
:autocmd BufEnter * cd %:p:h

:set switchbuf=usetab,split
:set spr
:let g:netrw_preview = 1
:let g:netrw_hide = 0
:let g:netrw_list_hide='^\..*'
:let g:netrw_bufsettings = 'nonu noma nomod nobl nowrap ro'
:let g:netrw_menu = 0
:let g:netrw_banner = 0
:let g:netrw_liststyle = 3


" Commenting blocks of code.
autocmd FileType c,cpp,java,scala let b:comment_leader = '// '
autocmd FileType sh,ruby,python   let b:comment_leader = '# '
autocmd FileType conf,fstab       let b:comment_leader = '# '
autocmd FileType r                let b:comment_leader = '# '
autocmd FileType tex,matlab       let b:comment_leader = '% '
autocmd FileType mail             let b:comment_leader = '> '
autocmd FileType vim              let b:comment_leader = '" '


" vim-latex
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_CompileRule_pdf = 'latexmk -pdf -f $*'
set iskeyword+=:

" Comment text
function! Comment() range "Step through each line in the range...

    let s:spaces = "-"

    for linenum in range(a:firstline, a:lastline)
        let curr_line   = getline(linenum)
        let replacement = substitute(curr_line,'\(^\s*\).*','\1','')
        if curr_line !~ "^$"
            if s:spaces =~ "-"
                let s:spaces = replacement
            else
                if strlen(replacement)<strlen(s:spaces)
                    let s:spaces = replacement
                endif
            endif
        endif
    endfor


    for linenum in range(a:firstline, a:lastline)
        let curr_line   = getline(linenum)
        if curr_line !~ "^$"
            let replacement = substitute(curr_line,'^'.s:spaces,s:spaces.b:comment_leader,'')
        else
            let replacement = substitute(curr_line,'^',s:spaces.b:comment_leader,'')
        endif
        call setline(linenum, replacement)
    endfor

endfunction

" Uncomment text
function! Uncomment() range "Step through each line in the range...

    for linenum in range(a:firstline, a:lastline)
        let curr_line   = getline(linenum)
        let replacement = substitute(curr_line,'^\(\s*\)'.b:comment_leader.'\(\s*\)','\1\2','')
        call setline(linenum, replacement)
    endfor

endfunction

com! -range Comment <line1>,<line2>call Comment()
com! -range Uncomment <line1>,<line2>call Uncomment()
map zc :Comment<CR>
map zv :Uncomment<CR>


" Solve the issue of formatting comments
" @param delimiter  the comment delimiter for the chosen filetype"
function! IndentComments(delimiter) range

    " set a temporary substitute for the delimiter
    let s:tmp_delimiter = 'delimiter>>>>'

    " replace the delimiter with the substitute
    exec a:firstline.','.a:lastline.' '.'s/%/'.s:tmp_delimiter.'/'

    " reformat all lines in the range
    exec a:firstline.','.a:lastline.' '.'normal! =='

    " put back the original delimiter
    exec a:firstline.','.a:lastline.' '.'s/'.s:tmp_delimiter.'/%/'

endfunction

" mapping '§' to reformat selected code in latex
:map <silent> § :call IndentComments("%") <CR>
set background=dark
" put the path of your clang library
let g:clang_library_path='/usr/lib/llvm-8/lib/libclang-8.so.1'


let g:jupytext_command = 'notedown'
" python
let g:jupytext_fmt = 'markdown'
let g:jupytext_to_ipynb_opts = '--to=notebook'
" put the path of your python interpreter
let g:python3_host_prog=expand('~/venv3/bin/python')

" spell
set spelllang=en_gb spell
set spellfile=$HOME/Dropbox/vim/spell/en.utf-8.add

" highlight
hi clear DiffAdd
hi clear DiffChange   
hi clear DiffDelete   
hi clear DiffText     
hi clear SpellBad                                                
hi clear SpellRare                                               
hi clear SpellCap                                                
hi clear SpellLocal
hi SpellBad     cterm=underline                                      
hi SpellRare    cterm=underline                                     
hi SpellCap     cterm=underline                                      
hi SpellLocal   cterm=underline
hi Comment                      ctermfg=lightblue
hi Pmenu                        ctermfg=15          ctermbg=0 
hi Visual       cterm=bold      ctermfg=Black       ctermbg=DarkBlue 
hi DiffAdd                      ctermfg=Black       ctermbg=DarkGreen
hi DiffChange                   ctermfg=Black       ctermbg=Yellow
hi DiffDelete                   ctermfg=LightBlue   ctermbg=NONE
hi DiffText                     ctermfg=Yellow      ctermbg=DarkRed

