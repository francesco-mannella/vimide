" =================================================================================================
" File:        vimide.vim
" Description: Converts Vim into a lightweight Python IDE
" Author:      Francesco Mannella <francesco.mannella@gmail.com> 
" Licence:     Vim licence
" Website:     https://github.com/francesco-mannella/vimide
" Version:     0.0.1
" Dependencies: tagbar.vim, youcompleteme, ctags
"
" Note: This script sets up Vim as an IDE with four windows, which include a tagbar, an editing window,
"       and a file explorer. It provides functionality for finding occurrences of words, resetting the 
"       IDE layout, opening files under the cursor, and more.
" 
" Interface:
" --------------------------------------------------------------------
" |                |                      |                          |
" |    Tagbar      |      Editor          |           Files          |
" |                |                      |                          |
" --------------------------------------------------------------------
"
" Tagbar:
" - Double-click with mouse: Move to function/class/method definition
" - Keyboard <return>: Move to function/class/method definition
"
" Normal mode shortcuts:
" ,cp -> Open or reset IDE for Python visualization
" ,cf -> Find occurrences of the word under cursor and display list in the editing window (grep-style)
" ,cg -> Move to the file containing the selected occurrence in the find list window
" ,cr -> Replace modified lines in the corresponding file from the find list
" ,cu -> Update the file lists
" 
" -------------------------------------------------------------------------------------------------
scriptencoding utf-8

" Location of tags file
let g:tags=trim(system("mktemp"))
" Case-insensitive search
set noci 
" Avoid 'object::object' tokens
set iskeyword-=: 

" Working directory when Vim is opened
let g:cwd = ""
let g:netrw_chgwin=2 

" GetCurrDir: Returns the current working directory
function! GetCurrDir()
    return system('echo -n $(pwd)')
endfunction

" ResetCtags: Reset the ctags database
" Description: Executes ctags over all subdirectories to rebuild the tag database
function! ResetCtags()
    execute "silent !ctags -R --c-types=+l --python-kinds=-i --langdef=C++ --sort=yes --c++-kinds=+cdefglmnpstuvx --fields=+imatS --extra=+q -f ".g:tags." ."
endfunction

" GotoMainWindow: Go to the source window
" Description: Positions the pointer in the central (editing) window
function! GotoMainWindow()
    wincmd t
    wincmd l
endfunction

" LeftTagbarToggle: Open the tagbar on the left
" Description: Calls TagbarToggle and then rearranges the windows layout
function! LeftTagbarToggle() 
    let w:jumpbacktohere = 1
    :TagbarToggle
    wincmd J
    wincmd k
    wincmd L
    wincmd R

    " Jump back to the original window"
    for window in range(1, winnr('$'))
        execute window . 'wincmd w'
        if exists('w:jumpbacktohere')
            unlet w:jumpbacktohere
            break
        endif
    endfor  
endfunction

" OpenFileUnderCursor: Open the file under cursor
" Description: Changes the directory and opens the file under cursor
function! OpenFileUnderCursor(nr) 
    execute ':cd '.g:cwd 
    let mycurf=expand("<cfile>")
    for window in range(1, winnr('$'))
        execute window . 'wincmd w'
        if window == a:nr
            break
        endif
    endfor
    execute ':cd '.g:cwd 
    execute ':e '.mycurf
endfunction

" =================================================================================================

let g:separator = '°'
let g:replacebuffer = -1

" FindOccurrence: Find occurrences of a pattern
" Description: Searches for occurrences of the specified pattern in source files, displaying results in a temporary buffer
function! FindOccurrence(atom)
    call GotoMainWindow()
    let g:replacebuffer = bufnr(bufname('%'))

    :silent !rm -fr /tmp/replace
    :e! /tmp/replace 
    :1,$d

    let findstring = 'silent r! find '.g:cwd.'/ | grep "\.\(cpp\|h\|hpp\|py\)$"'
    let findstring .= '| xargs grep -n "\<'.a:atom.'\>" | '
    let findstring .= 'sed -e"s/^\([^:]\+\/\([^\/^:]\+\)\):\([^:]\+\):\(.*\)/\2'.g:separator.'\3'.g:separator.'\4'.g:separator.'\1/"' 

    execute findstring
endfunction

" Replace: Replace modified lines in corresponding files
" Description: If a replacement list is displayed, commits changes to corresponding files
function! Replace()
    call GotoMainWindow()
    if bufname("%") == 'replace'
        wa
        let lines = readfile('/tmp/replace')
        for line in lines 
            if match(line,'^\s*$') == -1
                let replist = split(line,g:separator)
                let remotelines = readfile(replist[3])
                let remotelines[replist[1]-1] = replist[2]
                echo remotelines[replist[1]-1]
                set autoread
                call writefile(remotelines, replist[3] )
            endif
        endfor
        call input("Press Enter to return to buffer")
        execute ":b".g:replacebuffer
        :e! 
        :silent !rm -fr /tmp/replace    
    endif
endfunction

" FindUnderCursor: Find occurrences of the word under cursor
" Description: Finds and lists all occurrences of the word under the cursor in the source files
function! FindUnderCursor()
    let atom = expand('<cword>')
    call FindOccurrence(atom)
endfunction

" GotoUnderCursor: Go to the occurrence under cursor
" Description: Navigates to the file and line number of the occurrence under cursor in the find list
function! GotoUnderCursor()
    let line = getline('.')
    let test_string = g:separator.'\([0-9]\+\)'.g:separator
    echo test_string 

    if line =~ test_string
        let replist = split(line,g:separator)
        let path =  replist[3]
        let num =  replist[1]
        execute ':cd '.g:cwd 
        execute ':e '.path
        execute ':'.num
    endif 
endfunction

" =================================================================================================

" FormatPyIDE: Adjust the width of windows
" Description: Formats the window layout for the Python IDE
function! FormatPyIDE()
    echo '<format'
    wincmd t
    wincmd l
    vertical resize 200 
endfunction

" CreatePyView: Initialize the file explorer
" Description: Opens the file explorer in the working directory
function! CreatePyView()
    execute ":cd ".g:cwd 
    echo g:cwd
    silent :Ex .
endfunction

" RunPyIDE: Set up IDE for Python development
" Description: Initializes the IDE layout for managing Python projects
function! RunPyIDE()
    let g:IDE = "PyIDE"

    if g:cwd == ""
        let g:cwd = GetCurrDir()
    else
        bwipeout
        execute ":cd ".g:cwd 
    endif
    
    let pys = split(glob('`find '.g:cwd.'/ | grep -v build | grep "\.py$"`'),'\n')    

    wincmd o
    bwipeout
    let has_main = 0
    for py in pys 
        if py =~ "main"
            silent execute ":e ".py 
            let has_main = 1
        endif
    endfor
    if has_main == 0  
        silent execute ":e ".pys[0] 
    endif
    call LeftTagbarToggle()
    wincmd t
    wincmd l
    vsplit 
    call CreatePyView() 
    wincmd t
    wincmd l    
    wincmd l    
    call FormatPyIDE()
    call ResetCtags()
endfunction

" =================================================================================================

" UpdateView: Update the file explorer
" Description: Updates the file list based on the current IDE type
function! UpdateView()
    if g:IDE == "PyIDE"
        wincmd l        
        wincmd l        
        call CreatePyView()
    elseif g:IDE == "CppIDE"
        wincmd t        
        wincmd t
        call CreateHView()
        wincmd j
        call CreateCppView()
    endif
endfunction

" =================================================================================================

" Key mappings for IDE functionality
nmap ,cp :call RunPyIDE()<CR>
nmap ,cf :call FindUnderCursor()<CR>
nmap ,cg :call GotoUnderCursor()<CR>
nmap ,cr :call Replace()<CR>
nmap ,cu :call UpdateView()<CR>
nmap ,f :call OpenFileUnderCursor(2)<CR>

" Autocmd group for window resizing
augroup vimide
    au!

    au WinLeave *Netrw* :vertical res 2 
    au WinEnter *Netrw* :vertical res 200
    au WinLeave *Tagbar* :vertical res 2 
    au WinEnter *Tagbar* :vertical res 200 

augroup END
au VimResized * call FormatPyIDE()
