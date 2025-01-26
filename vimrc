set nocompatible             
filetype off                  

" open vim-plug
call plug#begin()

Plug 'vim-latex/vim-latex'
Plug 'davidhalter/jedi-vim'
Plug 'dense-analysis/ale', {'do': 'pip install python-lsp-server'}
Plug 'majutsushi/tagbar'
Plug 'francesco-mannella/vimide'
Plug 'goerz/jupytext.vim'
Plug 'will133/vim-dirdiff'
Plug 'anosillus/vim-ipynb'
Plug 'jpalardy/vim-slime'
Plug 'hanschen/vim-ipython-cell'
Plug 'kshenoy/vim-signature'
Plug 'acarapetis/vim-sh-heredoc-highlighting'
Plug 'madox2/vim-ai'
Plug 'arzg/vim-sh'
Plug 'markonm/traces.vim'
Plug 'instant-markdown/vim-instant-markdown', {'for': 'markdown', 'do': 'yarn install'}
Plug 'vim-scripts/loremipsum'
Plug 'nathanaelkane/vim-indent-guides'

call plug#end()            

filetype plugin indent on    
filetype plugin on
let g:tex_flavor='latex'

"jedi-vim
let g:jedi#popup_select_first = 0
autocmd FileType python setlocal completeopt-=preview 
autocmd FileType python setlocal completeopt-=popup 
let g:pymode_rope = 0
let g:jedi#show_call_signatures = "0"

"general 
se t_Co=256
se mouse-=a

map <silent> <Up> gk
imap <silent> <Up> <C-o>gk
map <silent> <Down> gj
imap <silent> <Down> <C-o>gj
map <silent> <home> g<home>
imap <silent> <home> <C-o>g<home>
map <silent> <End> g<End>
imap <silent> <End> <C-o>g<End>

se clipboard=unnamed

function! ClipboardYank()
  call system('xclip -i -selection clipboard', @@)
endfunction
function! ClipboardPaste()
  let @@ = system('xclip -o -selection clipboard')
endfunction


vnoremap <silent> ay y:call ClipboardYank()<cr>
nnoremap <silent> ap p:call ClipboardPaste()<cr>

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
":colorscheme late_evening "https://raw.githubusercontent.com/h3xx/vim-late_evening/main/colors/late_evening.vim
:colorscheme late_evening
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
set nocompatible
set grepprg=grep\ -nH\ $*
let g:tex_flavor='latex'
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_CompileRule_pdf = 'latexmk -pdf -f $*; latexmk -c'
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

" Close hidden buffers
function! CloseHiddenBuffers()
  " figure out which buffers are visible in any tab
  let visible = {}
  for t in range(1, tabpagenr('$'))
    for b in tabpagebuflist(t)
      let visible[b] = 1
    endfor
  endfor
  " close any buffer that's loaded and not visible
  for b in range(1, bufnr('$'))
    if bufloaded(b) && !has_key(visible, b)
      exe 'bd ' . b
    endif
  endfor
endfun
command! Bdi :call CloseHiddenBuffers()



" mapping '§' to reformat selected code in latex
:map <silent> § :call IndentComments("%") <CR>
" put the path of your clang library
let g:clang_library_path='/usr/lib/llvm-10/lib/libclang-10.so.1'


let g:jupytext_enable = 1
let g:jupytext_command = 'jupytext'
let g:jupytext_fmt = 'py:percent'
let g:jupytext_to_ipynb_opts = '--to=ipynb --update' 

" put the path of your python interpreter
let g:python3_host_prog=expand('~/venv3/bin/python')

" spell
" set spelllang=en_gb spell
" set spellfile=$HOME/.vim/spell/en.utf-8.add

" DirDff
let g:DirDiffExcludes = "CVS,*.class,*.o,*.pyc,.py_sources,.tags,*.jpg,*.png,.avi,*.npy,*.gif"                                                                                


" Highlights
hi Error NONE
hi ErrorMsg NONE
hi IPythonCell ctermbg=6 ctermfg=0

"------------------------------------------------------------------------------
" slime configuration 
"------------------------------------------------------------------------------
" " always use tmux
" let g:slime_target = 'tmux'
" 
" " fix paste issues in ipython
let g:slime_python_ipython = 1
" 
" " always send text to the top-right pane in the current tmux tab without asking
" let g:slime_default_config = {
"             \ 'socket_name': get(split($TMUX, ','), 0),
"             \ 'target_pane': '{top-right}' }
" let g:slime_dont_ask_default = 1

"------------------------------------------------------------------------------
" ipython-cell configuration
"------------------------------------------------------------------------------
" Keyboard mappings. <Leader> is \ (backslash) by default

" map <Leader>s to start IPython
autocmd FileType sh nnoremap <Leader>ss :SlimeSend1 echo "connect"<CR>
autocmd FileType python nnoremap <Leader>ss :SlimeSend1 ipython qt <CR>
autocmd FileType python nnoremap <Leader>as :SlimeSend1 ipython agg<CR>

" map <Leader>1r to run script
autocmd FileType python nnoremap <Leader>rr :IPythonCellRun<CR>

" map <Leader>1R to run script and time the execution
autocmd FileType python nnoremap <Leader>RR :IPythonCellRunTime<CR>

" map <Leader>lc to execute the current cell
autocmd FileType python nnoremap <Leader>cc :IPythonCellExecuteCell<CR>

" map <Leader>lv to execute the current cell
autocmd FileType python nnoremap <Leader>vv :IPythonCellExecuteCellVerbose<CR>:IPythonCellNextCell<CR>

" map <Leader>ll to execute the current cell and jump to the next cell
autocmd FileType python nnoremap <Leader>ll :IPythonCellClear<CR>:IPythonCellExecuteCellJump<CR>

" map <Leader>LL to clear IPython screen
autocmd FileType python nnoremap <Leader>LL :IPythonCellClear<CR>

" map <Leader>x to close all Matplotlib figure windows
autocmd FileType python nnoremap <Leader>xx :IPythonCellClose<CR>

" map [c and ]c to jump to the previous and next cell header
autocmd FileType python nnoremap [c :IPythonCellPrevCell<CR>
autocmd FileType python nnoremap ]c :IPythonCellNextCell<CR>

" map <Leader>1h to send the current line or current selection to IPython
autocmd FileType python nmap <Leader>hh <Plug>SlimeLineSend
autocmd FileType python xmap <Leader>hh <Plug>SlimeRegionSend
autocmd FileType python nmap <silent> <Leader>aa <Plug>SlimeLineSend :norm! j<CR>
autocmd FileType python xmap <silent> <Leader>aa <Plug>SlimeRegionSend :norm! `><CR>:norm! j<CR>
autocmd FileType bash nmap <Leader>hh <Plug>SlimeLineSend
autocmd FileType bash xmap <Leader>hh <Plug>SlimeRegionSend
autocmd FileType bash nmap <silent> <Leader>aa <Plug>SlimeLineSend :norm! j<CR>
autocmd FileType bash xmap <silent> <Leader>aa <Plug>SlimeRegionSend :norm! `><CR>:norm! j<CR>
 
" map <Leader>Q to restart ipython
autocmd FileType python nnoremap <Leader>QQ :IPythonCellRestart<CR>

" map <Leader>d to start debug mode
autocmd FileType python nnoremap <Leader>dd :execute 'SlimeSend1 %run -d' expand('%:p')  <CR>

" map <Leader>q to exit debug mode or IPython
autocmd FileType python nnoremap <Leader>qq :SlimeSend1 exit<CR>

" map <F9> and <F10> to insert a cell header tag above/below and enter insert mode
autocmd FileType python nmap <F9> :IPythonCellInsertAbove<CR>a
autocmd FileType python nmap <F10> :IPythonCellInsertBelow<CR>a

" also make <F9> and <F10> work in insert mode
autocmd FileType python imap <F9> <C-o>:IPythonCellInsertAbove<CR>
autocmd FileType python imap <F10> <C-o>:IPythonCellInsertBelow<CR>

let g:ipython_cell_cell_command = '%paste'
let g:ipython_cell_tag = ['# %%', '#%%']
let g:ipython_cell_prefer_external_copy = 1

" marks
hi SignColumn ctermbg=none
hi SignatureMarkText ctermfg=White

" Instant-Markdown-preview
let g:instant_markdown_mathjax = 1

" indent gudark     
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1
let g:indent_guides_auto_colors = 0
hi IndentGuidesOdd  ctermbg=236
hi IndentGuidesEven ctermbg=234

" ALE

let g:ale_completion_enabled = 0
let g:ale_linters = {'python': ['pylsp']}
let g:ale_fixers = {'python': ['black', 'autoflake', 'autopep8', 'isort', 'autoimport']}
let g:ale_python_black_options='-l 79'
let g:ale_sign_column_always = 1
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1

