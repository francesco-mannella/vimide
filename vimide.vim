" =================================================================================================
 
" File:        vimide.vim
" Description: Converts vim in a lightweight C++ IDE
" Author:      Francesco Mannella <francesco.mannella@gmail.com> 
" Licence:     Vim licence
" Website:     
" Version:     0.0.1
" Note:        Depends on tagbar.vim 
"
" Description:
"              RunIDE() finds all sources in the working dir 
"              and opens four windows:
"
"               ______________________________________________________
"              |                |                      |              |
"              |                |                      |   header     |
"              |                |                      |   list       |
"              |                |                      |              |
"              |  tagbar        |       edit           |______________|
"              |                |                      |              |
"              |                |                      |              |
"              |                |                      |    cpp       |
"              |                |                      |    list      |
"              |________________|______________________|______________|
"              
"
"              tagbar:
"                      
"                      - mouse double click    -> move to
"                      - keyboard <return>        function/class/method 
"                                                 definition 
"                    
"              header/cpp:
"                      
"                      - keyboard '+'          -> Open file in the edit
"                         (normal mode)           window
"                             
"
"              keyboard shortcuts 
"                   (normal mode):
"                      
"                                ,ci           -> Open or reset IDE
"
"                                ,cc           -> Create a new Class (making
"                                                 <classname>.h and 
"                                                 <classname>.cpp)
"                      
"                                ,cC           -> Clone a Class (making
"                                                 <newclassname>.h and 
"                                                 <newclassname>.cpp)
"                      
"                                ,cf           -> Finds the occurrences of the
"                                                 word under cursor and
"                                                 display a list in the edit
"                                                 window. Each row contains a
"                                                 grep-style visualization of
"                                                 the line where an occurrence is
"                                                 found. 
"
"                               ,cR            -> If a find list is currently
"                                                 displayed in the edit window
"                                                 each line that has been
"                                                 eventually modified is
"                                                 replaced in the
"                                                 corresponding file.
"
" =================================================================================================

scriptencoding utf-8

" loaction of tags file
set tags=./.tags
" case-sensitive search 
set noci 
" avoid 'object::object' tokens
set iskeyword-=: 

" working dir when vim is opened
let g:cwd = ""


function! GetCurrDir()
    return system('echo -n $(pwd)')
endfunction


" ResetCtags: reset the ctags database 
" Description: remotely executes ctags over all subdirs
function! ResetCtags()
    
    silent !ctags -R --c-types=+l --langdef=C++ --sort=yes --c++-kinds=+cdefglmnpstuvx --fields=+imatS --extra=+q -f '.tags' ..

endfunction

" GotoMainWindow: go to source window
" Description: position the pointer on the central window 
function! GotoMainWindow()

    wincmd t
    wincmd l

endfunction

" FormatIDE: reset the width of the windows
" Description: TODO 
function! FormatIDE()

    wincmd t
    vertical res 50
    wincmd l
    vertical res 100 
    wincmd l
    vertical res 50 
    wincmd j
    wincmd t
    wincmd l

endfunction

" CreateCppView: TODO
" Description: TODO 
function! CreateCppView()
        
    execute ":cd ".g:cwd 

    silent :e .cpp_sources 
    silent :se noro
    silent :1,$d
    silent r ! find | grep -v build | grep "\.cpp$"
    sort
    write
    set nonumber
    :1
    view!

endfunction

" CreateHView: TODO
" Description: TODO 
function! CreateHView()

    execute ":cd ".g:cwd 

    silent :e .h_sources 
    silent :se noro
    silent :1,$d
    silent r ! find | grep -v build | grep "\.h$"
    sort
    write
    set nonumber
    :1
    view!

endfunction

" CreateMainTemplate: TODO
" Description: TODO 
function! CreateMainTemplate(path)
    
    call GotoMainWindow()
    let main_cpp = a:path."main.cpp"
    
    let hlist = []
    call add(hlist,'#include <iostream>' )
    call add(hlist,''                    )
    call add(hlist,'int main()'          )
    call add(hlist,'{'                   )
    call add(hlist,'    return 0;'       )
    call add(hlist,'}'                   )

    call writefile(hlist,main_cpp)
    
endfunction

" CreateClassTemplate: TODO
" Description: TODO 
function! CreateClassTemplate()
    
    call GotoMainWindow()
    let path = GetCurrDir() 
    
    call inputsave() 
    let identifier = input("Class to create: ","")
    call inputrestore()

    let identifier = substitute(identifier,'^\(.\)','\U\1\E',"")
    let Lidentifier = substitute(identifier,'\(.*\)','\L\1\E',"")
    let Uidentifier = substitute(identifier,'\(.*\)','\U\1\E',"")  

    let filename_root = path.'/'.Lidentifier
    let filename_cpp = filename_root.".cpp"
    let filename_h = filename_root.".h"  
  
    
    let hlist = []
    call add(hlist,'#include "'.Lidentifier.'.h"')
    call add(hlist,'')
    call add(hlist,identifier.'::'.identifier.'()')
    call add(hlist,'{')
    call add(hlist,'}')
    call add(hlist,'')
    call add(hlist,'~'.identifier.'::'.identifier.'()')
    call add(hlist,'{')
    call add(hlist,'}')
    call add(hlist,'')
    call writefile(hlist,filename_cpp)
   
    let hlist = []
    call add(hlist,'#ifndef '.Uidentifier.'_H')
    call add(hlist,'#define '.Uidentifier.'_H')
    call add(hlist,'')
    call add(hlist,'class '.identifier)
    call add(hlist,'{')
    call add(hlist,'    public:')
    call add(hlist,'        '.identifier.'();')
    call add(hlist,'        ~'.identifier.'();')
    call add(hlist,'};')
    call add(hlist,'')
    call add(hlist,'#endif //'.Uidentifier.'_H')
    call add(hlist,'')
    call writefile(hlist,filename_h)

    call RunIDE()
 
endfunction

" RunIDE: TODO
" Description: TODO 
function! RunIDE()

    if g:cwd == ""
        let g:cwd = GetCurrDir()
        
        if isdirectory(g:cwd.'/src') == 0
            execute ':!mkdir '.g:cwd.'/src'
        endif
    else
        bwipeout
        execute ":cd ".g:cwd 
    endif
    
    let cpps = split(glob('`find '.g:cwd.'/| grep -v build | grep "\.cpp$"`'),'\n')    

    if len(cpps) == 0
        
        call CreateMainTemplate(GetCurrDir().'/src/')
        let cpps = split(glob('`find '.g:cwd.'/| grep -v build | grep "\.cpp$"`'),'\n')    
        
        endif
        
    wincmd o
    bwipeout
    
    silent execute ":e ".cpps[0] 
    call LeftTagbarToggle()
    wincmd t
    wincmd l
    vsplit 
    
    call CreateCppView() 
    wincmd t
    wincmd l    
    wincmd l    
    split
    call CreateHView()
      
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
 

let g:separator = '§'
let g:replacebuffer = -1

" FindOccurrence: TODO
" Description: TODO 
function! FindOccurrence(atom)
    
    call GotoMainWindow()
    let g:replacebuffer = bufnr(bufname('%'))

    :silent !rm -fr /tmp/replace
    :e! /tmp/replace 
    :1,$d

    let findstring = 'silent r! find '.g:cwd.'/| grep "\.\(cpp\|h\)$"'
    let findstring = findstring.'| xargs grep -n "\<'.a:atom.'\>" | '
    let findstring = findstring.'sed -e"s/^\([^:]\+\):\([^:]\+\):/\1'.g:separator.'\2'.g:separator.'/"' 

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
                let remotelines = readfile(replist[0])
                let remotelines[replist[1]-1] = replist[2]
                echo remotelines[replist[1]-1]
                call writefile(remotelines, replist[0] )
            endif
        endfor
        :bufdo e
        execute ":b".g:replacebuffer
        :silent !rm -fr /tmp/replace    
    endif
    
endfunction

" FindUnderCursor: TODO
" Description: TODO 
function! FindUnderCursor()

    let atom = expand('<cword>')
    call FindOccurrence(atom)

endfunction

" =================================================================================================
" =================================================================================================
" =================================================================================================
 
" RenameClassIdentifier: TODO
" Description: TODO 
function! RenameClassIdentifier(idnt,new_idnt)   

    call GotoMainWindow()
    let path = GetCurrDir() 

    let identifier = a:idnt
    let L_identifier = substitute(identifier,'\(.*\)','\L\1\E',"")
    let U_identifier = substitute(identifier,'\(.*\)','\U\1\E',"")
    let new_identifier = a:new_idnt
    let L_new_identifier = substitute(new_identifier,'\(.*\)','\L\1\E',"")
    let U_new_identifier = substitute(new_identifier,'\(.*\)','\U\1\E',"")

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


        let filename_root = path.'/'.L_new_identifier
        let filename_cpp = filename_root.".cpp"
        let filename_h = filename_root.".h"  

        for fname in [filename_cpp, filename_h]
            echo findfile(fname,"/") 
            if findfile(fname,"/") == fname

                silent execute ":e ".fname 
                try
                    silent execute ':%s/\<'.identifier.'\>/'.new_identifier.'/g'
                catch
                endtry
                try
                    silent execute ':%s/\<'.L_identifier.'\.h/'.L_new_identifier.'.h/g'
                catch
                endtry
                try
                    silent execute ':%s/\<'.U_identifier.'_H/'.U_new_identifier.'_H/g'
                catch
                endtry

                write

            endif
        endfor

        "echo " ...Done"

    else
        echo identifier." is not a class identifier!" 
    endif

endfunction

 
" CopyClass: TODO
" Description: TODO 
function! CopyClass()

    let path = GetCurrDir() 

    call inputsave() 
    let identifier = input("Class to copy: ","")
    call inputrestore()

    
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

        call inputsave() 
        let new_identifier = input("Rename: ",identifier)
        call inputrestore()

        let Lidentifier = substitute(identifier,'\(.*\)','\L\1\E',"")
        let Lnewidentifier = substitute(new_identifier,'\(.*\)','\L\1\E',"")


        let filename_root = path.'/'.Lidentifier
        let filename_cpp = filename_root.".cpp"
        let filename_h = filename_root.".h"  

        let filename_new_root = path.'/'.Lnewidentifier
        let filename_new_cpp = filename_new_root.".cpp"
        let filename_new_h = filename_new_root.".h"  

        if findfile(filename_h,"/") == filename_h 

            call GotoMainWindow()
            execute ":e ".filename_h
            execute ":sav ".filename_new_h

            if findfile(filename_cpp,"/") == filename_cpp 

                execute ":e ".filename_cpp
                execute ":sav ".filename_new_cpp

            endif

            call RunIDE()

            call RenameClassIdentifier(identifier,new_identifier)

        endif

    endif

endfunction

" =================================================================================================
" =================================================================================================
" =================================================================================================
 

nmap ,ci :silent call RunIDE()<CR>
nmap ,cc :call CreateClassTemplate()<CR>
nmap ,cC :call CopyClass()<CR>
nmap ,cf :call FindUnderCursor()<CR>
nmap ,cr :call Replace()<CR>
nmap + :call OpenFileUnderCursor(2)<CR>
