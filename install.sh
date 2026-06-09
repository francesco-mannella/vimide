#!/bin/bash

SRC_DIR="$(realpath "$(dirname -- "$0")")"

usage() {
    echo "Usage: $0 [-u] [-l]"
    echo "  (no flag)  Install vimide"
    echo "  -u         Uninstall vimide and restore previous settings"
    echo "  -l         Also install LaTeX support (texlive + latexmk + okular)"
    exit 1
}

# ── helpers ───────────────────────────────────────────────────────────────────

restore_or_remove() {
    local file=$1
    if [[ -f "${file}.orig" ]]; then
        echo "  Restoring ${file}"
        mv "${file}.orig" "${file}"
    elif [[ -f "${file}" ]]; then
        echo "  Removing  ${file}"
        rm "${file}"
    fi
}

# ── uninstall ─────────────────────────────────────────────────────────────────

uninstall() {
    echo "=== Uninstalling vimide ==="

    echo "Restoring config files..."
    restore_or_remove "${HOME}/.vimrc"
    restore_or_remove "${HOME}/.tmux.conf"
    restore_or_remove "${HOME}/.config/ai/roles.ini"
    restore_or_remove "${HOME}/.claude/CLAUDE.md"
    restore_or_remove "${HOME}/.claude/settings.json"

    echo "Removing ~/bin/vide..."
    rm -f "${HOME}/bin/vide"

    echo "Cleaning ~/.bashrc..."
    # Remove alias vim line
    sed -i '/alias vim="vim --servername vim"/d' "${HOME}/.bashrc"
    # Remove PATH line added by installer
    sed -i '/^export PATH=\$PATH:\${HOME}\/bin$/d' "${HOME}/.bashrc"
    # Remove SSH/DISPLAY snippet block (from marker to closing #####)
    sed -i '/^##### Fix SSH auth and DISPLAY inside Tmux$/,/^#####$/d' "${HOME}/.bashrc"

    echo "=== Uninstall complete ==="
    echo "Note: vim plugins and system packages (tmux, ctags) were not removed."
    echo "      To remove vim plugins: rm -rf ~/.vim/plugged"
}

# ── argument parsing ──────────────────────────────────────────────────────────

INSTALL_LATEX=0

while getopts "ul" opt; do
    case $opt in
        u) uninstall; exit 0 ;;
        l) INSTALL_LATEX=1 ;;
        *) usage ;;
    esac
done

# ── install ───────────────────────────────────────────────────────────────────

echo "=== Installing vimide ==="

# install vim-plug
if [ ! -f "${HOME}/.vim/autoload/plug.vim" ]; then
    echo "Installing vim-plug"
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "Updating ~/.vimrc"
[[ -f ${HOME}/.vimrc ]] && cp ${HOME}/.vimrc ${HOME}/.vimrc.orig
cp ${SRC_DIR}/scripts/vimrc ${HOME}/.vimrc

echo "Updating ~/.tmux.conf"
[[ -f ${HOME}/.tmux.conf ]] && cp ${HOME}/.tmux.conf ${HOME}/.tmux.conf.orig
cp ${SRC_DIR}/scripts/tmux.conf ${HOME}/.tmux.conf

echo "Updating plugins"
vim -T dumb -n -i NONE -e -S <(echo -e "silent! PlugUpdate\nqall")
echo "Installing plugins"
vim -T dumb -n -i NONE -e -S <(echo -e "silent! PlugInstall\nqall")

echo "Updating ai roles into ~/.config/ai"
mkdir -p "${HOME}/.config/ai"
[[ -f "${HOME}/.config/ai/roles.ini" ]] && cp "${HOME}/.config/ai/roles.ini" "${HOME}/.config/ai/roles.ini.orig"
cp "${SRC_DIR}/scripts/roles.ini" "${HOME}/.config/ai/roles.ini"

echo "Updating Claude settings"
mkdir -p "${HOME}/.claude"
[[ -f "${HOME}/.claude/CLAUDE.md" ]] && cp "${HOME}/.claude/CLAUDE.md" "${HOME}/.claude/CLAUDE.md.orig"
[[ -f "${HOME}/.claude/settings.json" ]] && cp "${HOME}/.claude/settings.json" "${HOME}/.claude/settings.json.orig"
cp "${SRC_DIR}/scripts/CLAUDE.md" "${HOME}/.claude/CLAUDE.md"
cp "${SRC_DIR}/scripts/settings.json" "${HOME}/.claude/settings.json"

echo "Installing Python modules"
uv pip install ipynb-py-convert
uv pip install notedown

echo "Installing tmux..."
sudo apt install -y tmux

echo "Installing ctags..."
sudo apt install -y universal-ctags

if [[ $INSTALL_LATEX -eq 1 ]]; then
    echo "Installing LaTeX support..."
    sudo apt install -y \
        texlive-latex-base \
        texlive-latex-recommended \
        latexmk \
        okular
fi

echo "Installing vide"
if [[ -z $(echo $PATH | grep ":${HOME}/bin:") ]]; then
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

echo "=== Installation complete ==="
