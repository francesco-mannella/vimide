#!/bin/bash

SRC_DIR="$(realpath "$(dirname -- "$0")")"

# install vim-plug
if [ -z "${HOME}/.vim/autoload/plug.vim" ]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

cp ${SRC_DIR}/vimrc ${HOME}/.vimrc

# install all plugins
vim -T dumb -n -i NONE -es -S <(echo -e "silent! PlugUpdate\nqall")
vim -T dumb -n -i NONE -es -S <(echo -e "silent! PlugInstall\nqall")

# install gemini conf or vim-ai
# -- you must also export your GEMINI_KEY in bashrc
mkdir -p ${HOME}/.config/ai 
cp ${SRC_DIR}/roles.ini ${HOME}/.config/ai/roles.ini
