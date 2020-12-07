#!/bin/bash

# Make config directory
mkdir -p ~/.config/nvim

# Make undo directory
mkdir -p ~/.vim_undo_files

# Link vim config
ln -s ~/Developer/dotfiles/cl-config/vim/init.vim ~/.config/nvim/init.vim

# Link coc config
ln -s ~/Developer/dotfiles/cl-config/vim/coc-settings.json ~/.config/nvim/coc-settings.json

# Install vim-plug
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Fix issue with <C-h> keybinding for vim
infocmp tmux-256color-italic | sed 's/kbs=^[hH]/kbs=\\177/' > tmux-256color-italic.ti
tic tmux-256color-italic.ti
rm tmux-256color-italic.ti

# Install vim plugins
vim +qall
