let g:jupytext_enable = 1
let g:jupytext_command = 'jupytext'
let g:jupytext_fmt = 'py:percent'
let g:jupytext_to_ipynb_opts = '--to=ipynb --update' 

" put the path of your python interpreter
let g:python3_host_prog=expand('~/venv3/bin/python')

" Highlights
hi Error NONE
hi ErrorMsg NONE
hi IPythonCell ctermbg=6 ctermfg=0

" " fix paste issues in ipython
let g:slime_python_ipython = 1

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

" ALE

let g:ale_completion_enabled = 0
let g:ale_linters = {
            \ 'python': ['pylsp', 'jedils'],
            \ 'tex': ['lacheck'],
            \}
let g:ale_fixers = {
            \ 'python': ['black','isort', 'autoimport'],
            \ 'sh': ['shfmt'],
            \ 'html': ['fecs', 'html-beautify', 'prettier', 'remove_trailing_lines', 'rustywind', 'tidy']
            \}

let g:ale_python_pylsp_config={'pylsp': {
  \ 'configurationSources': ['flake8'],
  \ 'plugins': {
  \   'flake8': {'enabled': v:true,  'ignore': "E203,E501,W503"  },
  \   'pycodestyle': {'enabled': v:false},
  \   'pyflakes': {'enabled': v:false},
  \   'pydocstyle': {'enabled': v:false},
  \   'pylsp_mypy': {'dmypy': v:true},
  \ },
  \ }}
let g:ale_python_black_options='-l 90'
let g:ale_sign_column_always = 1
let g:ale_set_loclist = 1
let g:ale_set_quickfix = 1
let g:ale_python_mypy_options = '--ignore-missing-imports'

function! ALEPreviewWindowClose()
    " Iterate through all buffer numbers
    for buf in range(1, bufnr('$'))
        " Check if the buffer is loaded before getting the name
        if bufloaded(buf)
            " Get the name of the buffer
            let bufferName = bufname(buf)
            " Close the buffer if its name is ALEPreviewWindow
            if bufferName ==# 'ALEPreviewWindow'
                execute 'bdelete' buf
            endif
        endif
    endfor
endfunction

nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)
nmap <silent> <C-f> <Plug>(ale_fix)
nmap <silent> <C-h> <Plug>(ale_hover)
nmap <silent> <C-x> :call ALEPreviewWindowClose()<CR>
