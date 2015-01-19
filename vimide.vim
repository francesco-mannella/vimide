" ============================================================================
" File:        vimide.vim
" Description: Setting and functions for vimide
" Author:      Francesco Mannella <francesco.mannella@gmail.com> 
" Licence:     Vim licence
" Website:     
" Version:     0.0.1
" Note:        Depends on tagbar.vim 
" ============================================================================

scriptencoding utf-8
set tags=./.tags

let g:main_window = -1
let g:cwd = ""

function! ResetCtags()
    silent !ctags -R --c-types=+l --sort=yes --c++-kinds=+cmdefgpstuv --fields=+imatS --extra=+q -f ".tags" ..
endfunction

function! FormatIDE()

    execute ":".g:main_window
    vertical res 150 
    wincmd h
    vertical res 50 
    execute ":".g:main_window
    wincmd l
    vertical res 50 
    execute ":".g:main_window

endfunction

function! CreateCppView()

    silent :e .cpp_sources 
    silent :se noro
    silent :1,$d
    silent r ! find ..| grep -v build | grep "\.cpp$"
    write
    set nonumber
    view!

endfunction

function! CreateHView()

    silent :e .h_sources 
    silent :se noro
    silent :1,$d
    silent r ! find ..| grep -v build | grep "\.h$"
    write
    set nonumber
    view!

endfunction

function! InitIDE()


    if g:cwd == ""
        let g:cwd = system("pwd")
        echo g:cwd
    else
        bwipeout
        execute ":cd ".g:cwd 
    endif


    let cpps = split(glob('`find ..| grep -v build | grep "\.cpp$"`'),'\n')    

    wincmd o
    bwipeout

    silent execute ":e ".cpps[0]
    let g:main_window = winnr()

    call LeftTagbarToggle()
    vsplit 

    call CreateCppView()
    execute ":".g:main_window


    split 
    call CreateHView()
    execute ":".g:main_window


    call FormatIDE()
    call ResetCtags()

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

    let mycurf=expand("<cfile>")
    for window in range(1, winnr('$'))
        execute window . 'wincmd w'
        if window == a:nr
            break
        endif
    endfor  
    :execute("e ".mycurf)

endfunction

" ****************************************************************** 
" ****************************************************************** 
" ****************************************************************** 

function! GetPreviousWord(curpos,curline) 

    let prev_w = substitute(a:curline[0:a:curpos],'\(\(\.\)\|\(::\)\|\(->\)\|\(\*\)\|\(&\)\)',' ','')
    let prev_w = substitute(prev_w,'^\(.*\)\s\+\(\S\+\)$','\1','')
    let prev_w = substitute(prev_w,'^\(\S\+\)\s\+\(\S\+\)$','\2','')
    let prev_w = substitute(prev_w,'^\s\+','','')
    let prev_w = substitute(prev_w,'\s\+$','','')

    if prev_w == a:curline
        let prev_w = "<EOR>"
    endif

    return prev_w

endfunction


function! GetPreviousWordUnderCursor() 

    let curpos = getpos('.')[2]
    let curline = getline('.')

    return GetPreviousWord(curpos,curline)

endfunction



function! GetTagClass(atom)
    if a:atom == ''
        let atom = GetPreviousWordUnderCursor()
    else
        let atom = GetPreviousWord(len(a:atom),a:atom)
    endif
    echo "atom:".atom
    let curtaglist = taglist('\<'.atom.'\>') 
    echo curtaglist


    let res_class = 'NOCLASS'

    if len(curtaglist) >0 

        for tagl in curtaglist

            if has_key(tagl,'class') 
                echo ":".tagl.class
                let res_class = tagl['class']
                break
            else
                let next_atom = substitute(tagl.cmd,'\/\^\([^\^]\+'.atom.'\).*$','\1','')
                res_class = GetTagClass(next_atom)
                if res_class !=  'NOCLASS'
                    break
                endif
            endif

        endfor 
    endif
    return res_class

endfunction


" ****************************************************************** 
" ****************************************************************** 
" ****************************************************************** 

let g:unsaved_bufs = []
let g:curr_buffer = 1

function! RenameIdentifier(idnt)   

    se noic
    setlocal iskeyword-=:
    let g:curr_buffer = bufnr('%')

    let identifier = idnt

    let idlist = taglist(identifier)
    let isclass = 0
    for id in idlist
        if id['kind'] == 'c' 
            let isclass = 1
            break
        endif
    endfor

    " identifier is a class
    if isclass == 1 

        let Lidentifier = substitute(identifier,'\(.*\)','\L\1\E',"")
        let Uidentifier = substitute(identifier,'\(.*\)','\U\1\E',"")  

        let filename_root = substitute(bufname('%'),'[\.]\(.*\)',"","g")
        let filename_cpp = filename_root.".cpp"
        let filename_h = filename_root.".h"  
        let filename_h = filename_root.".h"  

        if empty(g:unsaved_bufs)

            call inputsave() 
            let new_identifier = input("Rename: ",identifier)
            call inputrestore()

            for filebuf in [filename_cpp, filename_h]
                if bufexists(filebuf)
                    silent execute ":b".bufnr(filebuf) 
                    let l = line('.')
                    try
                        silent execute ':%s/\<'.identifier.'\>/'.new_identifier.'/g'
                    catch
                    endtry
                    try
                        silent execute ':%s/\<'.Lidentifier.'\.h/\L'.new_identifier.'\E.h/g'
                    catch
                    endtry
                    try
                        silent execute ':%s/\<'.Uidentifier.'_H/\U'.new_identifier.'\E_H/g'
                    catch
                    endtry
                    silent execute ":".l
                    call add(g:unsaved_bufs,bufnr(filebuf))
                    silent execute ":b".g:curr_buffer 
                endif
            endfor

            for bnr in g:unsaved_bufs
                if bnr != g:curr_buffer
                    silent execute ":split " 
                    silent execute ":b".bnr 
                endif
            endfor

        else

            call inputsave() 
            let save_req = input("Save?[Yes/No]: ","No")
            call inputrestore()

            let unsaved_wins = map(copy(g:unsaved_bufs),'bufwinnr(v:val)')
            call remove(unsaved_wins,index(g:unsaved_bufs,g:curr_buffer))


            if save_req == "Yes"

                for bnr in g:unsaved_bufs
                    silent execute ":b".bnr 
                    silent write
                endfor
                for wnr in unsaved_wins
                    silent execute ":".wnr 
                    silent execute ":q" 
                endfor

                let g:unsaved_bufs = []

            elseif save_req == "No"

                for bnr in g:unsaved_bufs
                    silent execute ":b".bnr 
                    silent undo
                endfor
                for wnr in unsaved_wins
                    silent execute ":".wnr 
                    silent execute ":q" 
                endfor

                let g:unsaved_bufs = []

            endif

            echo " ...Done"

        
        endif
    else
        echo identifier." is not a class identifier!" 
    endif

endfunction


function! RenameClassIdentifier(idnt,new_idnt)   

    let identifier = idnt
    let new_identifier = new_idnt

    let idlist = taglist(identifier)
    let isclass = 0
    for id in idlist
        if id['kind'] == 'c' 
            let isclass = 1
            break
        endif
    endfor

    " identifier is a class
    if isclass == 1 

        let Lidentifier = substitute(identifier,'\(.*\)','\L\1\E',"")
        let Uidentifier = substitute(identifier,'\(.*\)','\U\1\E',"")  

        let filename_root = expand("%:p:t:r")
        let filename_cpp = filename_root.".cpp"
        let filename_h = filename_root.".h"  
        let filename_h = filename_root.".h"  



        for filebuf in [filename_cpp, filename_h]
            if bufexists(filebuf)
                silent execute ":b".bufnr(filebuf) 
                let l = line('.')
                try
                    silent execute ':%s/\<'.identifier.'\>/'.new_identifier.'/g'
                catch
                endtry
                try
                    silent execute ':%s/\<'.Lidentifier.'\.h/\L'.new_identifier.'\E.h/g'
                catch
                endtry
                try
                    silent execute ':%s/\<'.Uidentifier.'_H/\U'.new_identifier.'\E_H/g'
                catch
                endtry
            endif
        endfor



        for filebuf in [filename_cpp, filename_h]
            silent execute ":b".bufnr(filebuf) 
            silent write
        endfor

        silent execute ":b".g:curr_buffer 

        echo " ...Done"

        endif
    else
        echo identifier." is not a class identifier!" 
    endif

endfunction


function! CopyClassUnderCursor()

    se noic
    setlocal iskeyword-=:

    let path = expand("%:p:h")."/"
    let g:curr_buffer = bufnr('%')
    let identifier = expand('<cword>')
    
    call inputsave() 
    let new_identifier = input("Rename: ",identifier)
    call inputrestore()
    
    let class_buf = bufnr('%')
    let Lidentifier = substitute(identifier,'\(.*\)','\L\1\E',"")
    let Lnewidentifier = substitute(new_identifier,'\(.*\)','\L\1\E',"")
   
    if findfile(path.Lidentifier.".h","/") == path.Lidentifier.".h" 

        execute ":e ".path.Lidentifier.".h"
        execute ":sav ".path.Lnewidentifier.".h"

        if findfile(path.Lidentifier.".cpp","/") == path.Lidentifier.".cpp" 
            execute ":e ".path.Lidentifier.".cpp"
            execute ":sav ".path.Lnewidentifier.".cpp"
        endif

        call InitIDE()
        call InitIDE()

        "RenameClassIdentifier(identifier,new_identifier)

    endif

endfunction


nmap <C-F2> :silent call InitIDE()<CR>
nmap <C-F3> :call FormatIDE()<CR>
nmap r :call RenameClassIdentifierUnderCursor()<CR>
nmap + :call OpenFileUnderCursor(2)<CR>
nmap R ;call ResetCtags()<CR>
nmap <F5> :echo GetTagClass('')<CR>
nmap <C-F8> :call CopyClassUnderCursor()<CR>

