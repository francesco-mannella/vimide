### VimIDE

Converts vim in a lightweight C++ IDE

#### Description
RunIDE() finds all sources in the working dir and opens four windows:

               ______________________________________________________
              |                |                      |              |
              |                |                      |   header     |
              |                |                      |   list       |
              |                |                      |              |
              |  tagbar        |       edit           |______________|
              |                |                      |              |
              |                |                      |              |
              |                |                      |    cpp       |
              |                |                      |    list      |
              |________________|______________________|______________|
              

              tagbar:
                      
                      - mouse double click    -> move to
                      - keyboard <return>        function/class/method 
                                                 definition 
                    
              header/cpp:
                      
                      - keyboard '+'          -> Open file in the edit
                         (normal mode)           window
                             

              keyboard shortcuts 
                   (normal mode):
                      
                                ,ci           -> Open or reset IDE

                                ,cp           -> Open or reset IDE for python
                                                 visualization

                                ,cc           -> Create a new Class (making
                                                 <classname>.h and 
                                                 <classname>.cpp)
                      
                                ,cC           -> Clone a Class (making
                                                 <newclassname>.h and 
                                                 <newclassname>.cpp)
                      
                                ,cf           -> Finds the occurrences of the
                                                 word under cursor and
                                                 display a list in the edit
                                                 window. Each row contains a
                                                 grep-style visualization of
                                                 the line where an occurrence is
                                                 found. 

                                ,cg           -> move to the file to which
                                                 the line under the cursor
                                                 belongs.
                                                 You must be within the find
                                                 list window (see .cf).

                                ,cr            -> If a find list is currently
                                                 displayed in the edit window
                                                 each line that has been
                                                 eventually modified is
                                                 replaced in the
                                                 corresponding file.

                                ,cu            -> Update the file lists



### INSTALL
mkdir -p ~/.vim/plugin/
curl https://raw.githubusercontent.com/francesco-mannella/vimide/master/vimide.vim > ~/.vim/plugin/vimide.vim

 
#### exuberant-ctags: 


    sudo apt-get install ctags


#### tagbar:


    git clone https://github.com/majutsushi/tagbar.git tagbar
    cd tagbar && git archive --format=tar HEAD | (cd ~/.vim/ && tar xf -) && cd ..
  
### SETTINGS
 
#### vim
    echo ":set spr" >> ~/.vimrc

### RECOMMENDED
 
#### vim
Install vundle:
    
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

and set ~/.vimrc with the vimide [vimrc](vimrc) template:

    curl https://raw.githubusercontent.com/francesco-mannella/vimide/master/vimrc >> ~/.vimrc

#### autocomplection in python through jedi and cpp through clang

Install jedi:

    python -m pip install jedi

Install libclang:

    sudo apt install libclang8-dev

Install vim plugins:

    vim +PluginInstall +qall
