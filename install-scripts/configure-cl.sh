#!/bin/bash

# Link the zshrc file
rm ~/.zshrc
ln -s ~/Developer/dotfiles/cl-config/zshrc ~/.zshrc

echo "Generating machine's ssh key..."
ssh-keygen -t rsa -b 4096 -C "kyle@kylegrinstead.com" -P "" -f ~/.ssh/id_rsa
echo

# Change shell to zsh
chsh -s /usr/local/bin/zsh

echo "Installing oh-my-zsh..."
# This env function is a hacky way to prevent a new shell from spawning when oh-my-zsh is done installing
env() {
  if ! [ \$1 = zsh ]; then /usr/bin/env \$@; fi;
}
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
echo

echo "Installing nvm..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh)"
echo

# Install and set Python version
pyenv install 3.4.4
pyenv global 3.4.4

# Install italics support for tmux
tic ./italics-support/tmux-256color-italic.terminfo

# Install fzf shell extensions
/usr/local/opt/fzf/install --key-bindings --completion --update-rc

# Link the git files
ln -s ~/Developer/dotfiles/cl-config/git/config ~/.gitconfig
ln -s ~/Developer/dotfiles/cl-config/git/gitignore ~/.gitignore_global

# Link the tmux.conf file
ln -s ~/Developer/dotfiles/cl-config/tmux.conf ~/.tmux.conf

# Link the zsh overrides file
ln -s ~/Developer/dotfiles/cl-config/zsh-overrides.zsh ~/.oh-my-zsh/custom/zsh-overrides.zsh

# Install sshpass (allows ssh commands to be run with the password inline; useful for doing server setup)
brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
