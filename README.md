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







### Install with Vundle

#### vim
* Install vundle:

        git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

* add this vundle snippet at the begin of your ~/vimrc:


      set nocompatible              " be iMproved, required
      filetype off                  " required

      " set the runtime path to include Vundle and initialize
      set rtp+=~/.vim/bundle/Vundle.vim
      call vundle#begin()

      " let Vundle manage Vundle, required
      Plugin 'VundleVim/Vundle.vim'

      Plugin 'vim-latex/vim-latex'
      Plugin 'davidhalter/jedi-vim'
      Plugin 'xavierd/clang_complete'
      Plugin 'majutsushi/tagbar'
      Plugin 'francesco-mannella/vimide'

      " All of your Plugins must be added before the following line
      call vundle#end()            " required
      filetype plugin indent on    " required

      "jedi-vim
      let g:jedi#popup_select_first = 0
      autocmd FileType python setlocal completeopt-=preview
      let g:pymode_rope = 0





* OR (recommended): set ~/.vimrc with the vimide [vimrc](vimrc) template:

        curl https://raw.githubusercontent.com/francesco-mannella/vimide/master/vimrc > ~/.vimrc
* install vim plugins:

      vim +PluginInstall +qall

### Install dependencies

#### autocomplection in python through jedi and cpp through clang

* jedi:


      python -m pip install jedi

* Install libclang:

      sudo apt install libclang8-dev

#### exuberant-ctags:

* Install clangs

      sudo apt-get install ctags

#### vim-ipynb

* Install ipynb-py-convert
    
      pip install ipynb-py-convert

* Install notedown

      pip install notedown
