set nocompatible             
filetype off                  

" open vim-plug
call plug#begin()

Plug 'lervag/vimtex'
Plug 'davidhalter/jedi-vim'
Plug 'dense-analysis/ale', {'do': 'python -m pip install python-lsp-server'}
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
Plug 'madox2/vim-ai-provider-google'
Plug 'arzg/vim-sh'
Plug 'markonm/traces.vim'
Plug 'instant-markdown/vim-instant-markdown', {'for': 'markdown', 'do': 'yarn install'}
Plug 'vim-scripts/loremipsum'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'mzlogin/vim-markdown-toc'
Plug 'eranfrie/gitgrep.vim'
Plug 'lervag/vimtex'

call plug#end()            

filetype plugin indent on    
filetype plugin on
let g:tex_flavor='latex'

"git-grep
let g:gitgrep_cmd = "git grep"
let g:gitgrep_exclude_files = ".pyc$"
"let g:loaded_gitgrep = 1



command -bang -nargs=* GG call GitGrep("", expand(<q-args>))
command -bang -nargs=* GGw call GitGrep("-w", expand(<q-args>))
command -bang -nargs=* GGi call GitGrep("-i", expand(<q-args>))
let g:gitgrep_menu_height = 2



nnoremap <leader>g :call GitGrep("-w", expand("<cword>"))<CR>
nnoremap <leader>t :call GitGrepBack()<CR>

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
      \ 'build_dir' : 'out',
      \ 'options' : [
      \   '-shell-escape',
      \   '-file-line-error',
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



" put the path of your clang library
let g:clang_library_path='/usr/lib/llvm-10/lib/libclang-10.so.1'



" spell
" set spelllang=en_gb spell
" set spellfile=$HOME/.vim/spell/en.utf-8.add

" DirDff
let g:DirDiffExcludes = "CVS,*.class,*.o,*.pyc,.py_sources,.tags,*.jpg,*.png,.avi,*.npy,*.gif"                                                                                



autocmd FileType bash nmap <Leader>hh <Plug>SlimeLineSend
autocmd FileType bash xmap <Leader>hh <Plug>SlimeRegionSend
autocmd FileType bash nmap <silent> <Leader>aa <Plug>SlimeLineSend :norm! j<CR>
autocmd FileType bash xmap <silent> <Leader>aa <Plug>SlimeRegionSend :norm! `><CR>:norm! j<CR>
 

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

" vim-ai
let g:vim_ai_roles_config_file = '~/.config/ai/roles.ini'

" markdown

" ==============================================================================
" Support function to 'slugify' a string
" Transforms "A Title With Spaces & Strange Characters" into "a-title-with-spaces--strange-characters"
" ==============================================================================
function! Slugify(text) abort
    " 1. Remove leading and trailing spaces
    let l:slug = trim(a:text)

    " 2. Convert to lowercase
    let l:slug = tolower(l:slug)

    
    " 4. Replace all non-alphanumeric characters (excluding spaces and hyphens) with a hyphen.
    "    Note: we use ' -' to keep existing hyphens and spaces.
    let l:slug = substitute(l:slug, '[^a-z0-9àáâãäåèéêëìíîïòóôõöùúûüç -]', '', 'g')
    
    " 5. Replace multiple spaces and hyphens with a single hyphen
    let l:slug = substitute(l:slug, '[ -]\+', '-', 'g')

    " 6. Remove residual leading and trailing hyphens
    let l:slug = substitute(l:slug, '^-', '', '')
    let l:slug = substitute(l:slug, '-$', '', '')
    
    return l:slug
endfunction

function! AddAnchorsToMarkdownHeadingsInRange(start, end) abort
    execute a:start . ',' . a:end . 'g/^\s*#\+\s\+.*$/s/^\(\s*#\+\)\s\+\(.*\)$/\=submatch(1) . " " . submatch(2) . " <a id=\"#" . Slugify(submatch(2)) . "\/>"/'
    echo "Markdown anchors added to headings in range"
endfunction

" Mappatura dei tasti in modalità visuale per chiamare la funzione su un intervallo di selezione
xnoremap <leader>mm :<C-u>call AddAnchorsToMarkdownHeadingsInRange('<','>')<CR>
