#!/bin/bash

SRC_DIR="$(realpath "$(dirname -- "$0")")"

# install vim-plug
if [ ! -f "${HOME}/.vim/autoload/plug.vim" ]; then
    echo "Installing vim-plug"
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "updating ~/.vimrc"
[[ -f ${HOME}/.vimrc ]] && cp ${HOME}/.vimrc ${HOME}/.vimrc.orig
cp ${SRC_DIR}/scripts/vimrc ${HOME}/.vimrc

echo "updating ~/.tmux.conf"
[[ -f ${HOME}/.tmux.conf ]] && cp ${HOME}/.tmux.conf ${HOME}/.tmux.conf.orig
cp ${SRC_DIR}/scripts/tmux.conf ${HOME}/.tmux.conf

echo "Updating plugins"
vim -T dumb -n -i NONE -e -S <(echo -e "silent! PlugUpdate\nqall")
echo "Installing plugins"
vim -T dumb -n -i NONE -e -S <(echo -e "silent! PlugInstall\nqall")

# install gemini conf or vim-ai
# -- you must also export your GEMINI_KEY in bashrc
echo "Updating ai roles into .config/ai directory"
mkdir -p "${HOME}/.config/ai"
[[ -f "${HOME}/.config/ai/roles.ini" ]] && cp "${HOME}/.config/ai/roles.ini" "${HOME}/.config/ai/roles.ini.orig"
cp "${SRC_DIR}/scripts/roles.ini" "${HOME}/.config/ai/roles.ini"

echo "Updating claude general settings"
mkdir -p "${HOME}/.claude"
[[ -f "${HOME}/.claude/CLAUDE.md" ]] && cp "${HOME}/.claude/CLAUDE.md" "${HOME}/.claude/CLAUDE.md.orig"
[[ -f "${HOME}/.claude/settings.json" ]] && cp "${HOME}/.claude/settings.json" "${HOME}/.claude/settings.json.orig"
cp "${SRC_DIR}/scripts/CLAUDE.md" "${HOME}/.claude/CLAUDE.md"
cp "${SRC_DIR}/scripts/settings.json" "${HOME}/.claude/settings.json"

echo "Installing python modules"
uv pip install ipynb-py-convert
uv pip install notedown

echo "Installing tmux ..."
sudo apt install -y tmux

echo "Installing ctags ..."
sudo apt install -y  universal-ctags

echo "installing vide"
if [[ -z $(echo $PATH| grep ":${HOME}/bin:") ]]; then
    echo 'export PATH=$PATH:${HOME}/bin' >> ${HOME}/.bashrc
fi
if [[ -z $(cat ${HOME}/.bashrc | grep "servername vim") ]]; then
   echo 'alias vim="vim --servername vim"' >> ${HOME}/.bashrc
fi

SNIPPET='##### Fix SSH auth and DISPLAY inside Tmux'
if ! grep -qF "$SNIPPET" ~/.bashrc; then
    cat << 'EOF' >> ~/.bashrc
##### Fix SSH auth and DISPLAY inside Tmux
if [ -n "$TRACK_SSH" ]; then
    export DISPLAY=$(tmux show-environment DISPLAY 2>/dev/null | cut -d= -f2-)
fi
#####
EOF
fi

mkdir -p ${HOME}/bin
cp ${SRC_DIR}/scripts/vide ${HOME}/bin/vide


