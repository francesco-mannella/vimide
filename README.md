" =================================================================================================
"
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