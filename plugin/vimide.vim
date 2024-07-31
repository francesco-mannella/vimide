" =================================================================================================
 
" File:        vimide.vim
" Description: Converts vim in a lightweight C++ IDE
" Author:      Francesco Mannella <francesco.mannella@gmail.com> 
" Licence:     Vim licence
" Website:     
" Version:     0.0.1
" Note:        Depends on tagbar.vim youcompleteme ctags 
"
" Description:
"              RunPyIDE() finds all sources in the working dir 
"              and opens four windows:
"
"               ______________________________________________________
"              |                |                      |              |
"              |                |                      |              |
"              |                |                      |              |
"              |                |                      |              |
"              |  tagbar        |       edit           |    files     |
"              |                |                      |              |
"              |                |                      |              |
"              |                |                      |              |
"              |                |                      |              |
"              |________________|______________________|______________|
"              
"
"              tagbar:
"                      
"                      - mouse double click    -> move to
"                      - keyboard <return>        function/class/method 
"                                                 definition 
"                    
"
"              keyboard shortcuts 
"                   (normal mode):
"                      
"                                ,cp           -> Open or reset IDE for python
"                                                 visualization
"
"                                ,cf           -> Finds the occurrences of the
"                                                 word under cursor and
"                                                 display a list in the edit
"                                                 window. Each row contains a
"                                                 grep-style visualization of
"                                                 the line where an occurrence is
"                                                 found. 
"
"                                ,cg           -> move to the file to which
"                                                 the line under the cursor
"                                                 belongs.
"                                                 You must be within the find
"                                                 list window (see .cf).
"
"                                ,cr            -> If a find list is currently
"                                                 displayed in the edit window
"                                                 each line that has been
"                                                 eventually modified is
"                                                 replaced in the
"                                                 corresponding file.
"                                ,cu            -> Update the file lists
"                           
" =================================================================================================

scriptencoding utf-8

" loaction of tags file
let g:tags=trim(system("mktemp"))
" case-sensitive search 
set noci 
" avoid 'object::object' tokens
set iskeyword-=: 

" working dir when vim is opened
let g:cwd = ""
let g:netrw_chgwin=2 


function! GetCurrDir()
    return system('echo -n $(pwd)')
endfunction


" ResetCtags: reset the ctags database 
" Description: remotely executes ctags over all subdirs
function! ResetCtags()
    
    execute "silent ! ctags -R --c-types=+l --python-kinds=-i --langdef=C++ --sort=yes --c++-kinds=+cdefglmnpstuvx --fields=+imatS --extra=+q -f ".g:tags." ."

endfunction


" GotoMainWindow: go to source window
" Description: position the pointer on the central window 
function! GotoMainWindow()

    wincmd t
    wincmd l

endfunction



" LeftTagbarToggle: open the tagbar on the left 
" Description: calls TagbarToggle and then rotate the two windows
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

" OpenFileUnderCursor: open the tagbar on the left 
" Description: calls TagbarToggle and then rotate the two windows
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
" =================================================================================================
" =================================================================================================
 

let g:separator = '°'
let g:replacebuffer = -1

" FindOccurrence: TODO
" Description: TODO 
function! FindOccurrence(atom)
    
    call GotoMainWindow()
    let g:replacebuffer = bufnr(bufname('%'))

    :silent !rm -fr /tmp/replace
    :e! /tmp/replace 
    :1,$d

    let findstring = 'silent r! find '.g:cwd.'/| grep "\.\(cpp\|h\|hpp\|py\)$"'
    let findstring = findstring.'| xargs grep -n "\<'.a:atom.'\>" | '
    let findstring = findstring.'sed -e"s/^\([^:]\+\/\([^\/^:]\+\)\):\([^:]\+\):\(.*\)/\2'.g:separator.'\3'.g:separator.'\4'.g:separator.'\1/"' 

    execute findstring

endfunction


" Replace: TODO
" Description: TODO 
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
        call input("Press to return to buffer")
        execute ":b".g:replacebuffer
        :e! 
        :silent !rm -fr /tmp/replace    
    endif
    
endfunction

" FindUnderCursor: TODO
" Description: TODO 
function! FindUnderCursor()

    let atom = expand('<cword>')
    call FindOccurrence(atom)

endfunction

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
" =================================================================================================
" =================================================================================================

" FormatPyIDE: reset the width of the windows
" Description: TODO 
function! FormatPyIDE()

    au WinLeave *Netrw* :vertical res 2 
    au WinEnter *Netrw* :vertical res 200
    au WinLeave *Tagbar* :vertical res 2 
    au WinEnter *Tagbar* :vertical res 200 
    wincmd t
    vertical res 200
    wincmd l
    vertical res 2
    wincmd l
    vertical res 2
    wincmd h
    vertical res 200


endfunction


" CreatePyView: TODO
" Description: TODO 
function! CreatePyView()
        
    execute ":cd ".g:cwd 
    
    echo g:cwd
    silent :Ex .

endfunction

" UpdatePyView: TODO
" Description: TODO 
function! UpdatePyView()
    wincmd l        
    wincmd l        
    CreatePyView()
endfunction


" RunIDE: TODO
" Description: TODO 
function! RunPyIDE()

    let g:IDE = "PyIDE"

    if g:cwd == ""
        let g:cwd = GetCurrDir()
    else
        bwipeout
        execute ":cd ".g:cwd 
    endif
    
    let pys = split(glob('`find '.g:cwd.'/| grep -v build | grep "\.py$"`'),'\n')    

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

" UpdateView: TODO
" Description: TODO 
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
" =================================================================================================
" =================================================================================================
 

nmap ,cp : call RunPyIDE()<CR>
nmap ,cf :call FindUnderCursor()<CR>
nmap ,cg :call GotoUnderCursor()<CR>
nmap ,cr :call Replace()<CR>
nmap ,cu :call UpdateView()<CR>
nmap <enter> :call OpenFileUnderCursor(2)<CR>
