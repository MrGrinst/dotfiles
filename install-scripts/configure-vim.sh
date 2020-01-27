#!/bin/bash

# Make config directory
mkdir -p ~/.config/nvim

# Make undo directory
mkdir -p ~/.vim_undo_files

# Link vim config
ln -s ~/Developer/dotfiles/cl-config/vim/init.vim ~/.config/nvim/init.vim

# Install vim-plug
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Fix issue with <C-h> keybinding for vim
infocmp tmux-256color-italic | sed 's/kbs=^[hH]/kbs=\\177/' > tmux-256color-italic.ti
tic tmux-256color-italic.ti
rm tmux-256color-italic.ti

# Install vim plugins
vim +PluginInstall +qall

# Install coc extensions
cd ~/.config/coc/extensions && yarn add coc-snippets https://github.com/MrGrinst/coc-git.git coc-pairs coc-solargraph coc-prettier coc-eslint coc-tsserver coc-diagnostic

# Install python module to support python plugins
python3 -m pip install --user --upgrade pynvim
