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

                                ,cp           -> Open or reset IDE for python
                                                 visualization

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







### Install with vim-plug

#### vim
* Install vim-plug:

      curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim


* add this snippet at the begin of your ~/vimrc:


      set nocompatible              " be iMproved, required
      filetype off                  " required

      call plug#begin()

      Plug 'vim-latex/vim-latex'
      Plug 'davidhalter/jedi-vim'
      Plug 'xavierd/clang_complete'
      Plug 'majutsushi/tagbar'
      Plug 'francesco-mannella/vimide'

      call plug#end()  

      filetype plugin indent on  


      let g:jedi#popup_select_first = 0
      autocmd FileType python setlocal completeopt-=preview 
      autocmd FileType python setlocal completeopt-=popup 
      let g:pymode_rope = 0
      let g:jedi#show_call_signatures = "0"

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
