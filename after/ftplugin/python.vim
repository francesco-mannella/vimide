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
nnoremap <buffer> <Leader>ss :SlimeSend1 ipython --pylab qt <CR>
nnoremap <buffer> <Leader>as :SlimeSend1 ipython --pylab agg<CR>

" map <Leader>1r to run script
nnoremap <buffer> <Leader>rr :IPythonCellRun<CR>

" map <Leader>1R to run script and time the execution
nnoremap <buffer> <Leader>RR :IPythonCellRunTime<CR>

" map <Leader>lc to execute the current cell
nnoremap <buffer> <Leader>cc :IPythonCellExecuteCell<CR>

" map <Leader>lv to execute the current cell
nnoremap <buffer> <Leader>vv :IPythonCellExecuteCellVerbose<CR>:IPythonCellNextCell<CR>

" map <Leader>ll to execute the current cell and jump to the next cell
nnoremap <buffer> <Leader>ll :IPythonCellClear<CR>:IPythonCellExecuteCellVerboseJump<CR>

" map <Leader>LL to clear IPython screen
nnoremap <buffer> <Leader>LL :IPythonCellClear<CR>

" map <Leader>x to close all Matplotlib figure windows
nnoremap <buffer> <Leader>xx :IPythonCellClose<CR>

" map [c and ]c to jump to the previous and next cell header
nnoremap <buffer> [c :IPythonCellPrevCell<CR>
nnoremap <buffer> ]c :IPythonCellNextCell<CR>

" map <Leader>hh and <Leader>aa to send line/region to IPython with prompt guard
function! s:IPythonAtEmptyPrompt() abort
    let l:cfg = exists('b:slime_config') ? b:slime_config :
              \ (exists('g:slime_config') ? g:slime_config : {})
    if empty(l:cfg) || !has_key(l:cfg, 'target_pane')
        return 1
    endif
    let l:output = system('tmux capture-pane -p -t ' . shellescape(l:cfg['target_pane']))
    let l:lines = filter(split(l:output, "\n"), 'v:val !~ "^\\s*$"')
    if empty(l:lines)
        return 0
    endif
    return trim(l:lines[-1]) =~# '^In \[\d\+\]:\s*$'
endfunction

function! s:SendLineChecked(advance) abort
    if !s:IPythonAtEmptyPrompt()
        echohl WarningMsg | echo "IPython: not at empty prompt" | echohl None
        return
    endif
    call slime#send_lines(1)
    if a:advance
        normal! j
    endif
endfunction

function! s:SendRegionChecked(advance) abort
    if !s:IPythonAtEmptyPrompt()
        echohl WarningMsg | echo "IPython: not at empty prompt" | echohl None
        return
    endif
    call slime#send_op(visualmode(), 1)
    if a:advance
        normal! `>
        normal! j
    endif
endfunction

nnoremap <buffer> <silent> <Leader>hh :call <SID>SendLineChecked(0)<CR>
xnoremap <buffer> <silent> <Leader>hh :<C-u>call <SID>SendRegionChecked(0)<CR>
nnoremap <buffer> <silent> <Leader>aa :call <SID>SendLineChecked(1)<CR>
xnoremap <buffer> <silent> <Leader>aa :<C-u>call <SID>SendRegionChecked(1)<CR>


" map <Leader>Q to restart ipython
nnoremap <buffer> <Leader>QQ :IPythonCellRestart<CR>

" map <Leader>d to start debug mode
nnoremap <buffer> <Leader>dd :execute 'SlimeSend1 %run -d' expand('%:p')  <CR>

" map <Leader>q to exit debug mode or IPython
nnoremap <buffer> <Leader>qq :SlimeSend1 exit<CR>

" map <F9> and <F10> to insert a cell header tag above/below and enter insert mode
nmap <buffer> <F9> :IPythonCellInsertAbove<CR>a
nmap <buffer> <F10> :IPythonCellInsertBelow<CR>a

" also make <F9> and <F10> work in insert mode
imap <buffer> <F9> <C-o>:IPythonCellInsertAbove<CR>
imap <buffer> <F10> <C-o>:IPythonCellInsertBelow<CR>

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

nnoremap <silent> <buffer> <C-k> :ALEPreviousWrap<CR>
nnoremap <silent> <buffer> <C-j> :ALENextWrap<CR>
nnoremap <silent> <buffer> <C-f> :ALEFix<CR>
nnoremap <silent> <buffer> <C-h> :ALEHover<CR>
nnoremap <silent> <buffer> <BS> :ALEHover<CR>
nnoremap <silent> <buffer> <C-x> :call ALEPreviewWindowClose()<CR>
