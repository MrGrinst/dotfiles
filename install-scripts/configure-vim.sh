#!/bin/bash

# Make config directory
mkdir -p ~/.config/nvim

# Make undo directory
mkdir -p ~/.vim_undo_files

# Map vim config to vim
ln -s ~/Developer/dotfiles/cl-config/vim/init.vim ~/.config/nvim/init.vim

# Install vim-plug
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Fix issue with <C-h> keybinding for vim
infocmp tmux-256color-italic | sed 's/kbs=^[hH]/kbs=\\177/' > tmux-256color-italic.ti
tic tmux-256color-italic.ti
rm tmux-256color-italic.ti

# Install neovim Python integration
pip3 install --upgrade neovim

# Install coderay for use in previewing files
gem install coderay

# Link the ctags file
ln -s ~/Developer/dotfiles/cl-config/ctags ~/.ctags

# Install vim plugins
vim +PluginInstall +qall
