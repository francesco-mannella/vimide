#!/bin/bash

SRC_DIR="$(realpath "$(dirname -- "$0")")"

# install vim-plug
if [ -z "${HOME}/.vim/autoload/plug.vim" ]; then
    echo "Installing vim-plug"
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "updating ~/.vimrc"
cp ${HOME}/.vimrc ${HOME}/.vimrc.orig
cp ${SRC_DIR}/vimrc ${HOME}/.vimrc  

echo "updating ~/.screenrc"
[[ -f ${HOME}/.screenrc ]] && cp ${HOME}/.screenrc ${HOME}/.screenrc.orig
cp ${SRC_DIR}/screenrc ${HOME}/.screenrc  


echo "Updating plugins"
vim -T dumb -n -i NONE -es -S <(echo -e "silent! PlugUpdate\nqall")
echo "Installing plugins"
vim -T dumb -n -i NONE -es -S <(echo -e "silent! PlugInstall\nqall")

# install gemini conf or vim-ai
# -- you must also export your GEMINI_KEY in bashrc
echo "Updating ai roles into .config/ai directory"
mkdir -p "${HOME}/.config/ai"
cp "${SRC_DIR}/roles.ini" "${HOME}/.config/ai/roles.ini"
