INSTALL

cp vimide.vim ~/.vim/plugin/

REQUIRES

exuberant-ctags: 
    sudo apt-get install ctags

tagbar
    git clone https://github.com/majutsushi/tagbar.git tagbar
    cd tagbar && git archive --format=tar HEAD | (cd ~/.vim/ && tar xf -) && cd ..

