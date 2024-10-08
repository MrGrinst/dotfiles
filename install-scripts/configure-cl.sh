#!/bin/bash

if [[ ! -f ~/.ssh/id_dsa ]]; then
  echo "Generating machine's ssh key..."
  ssh-keygen -t ed25519 -C "kyleag@hey.com" -P "" -f ~/.ssh/id_dsa
  echo
fi

# Change shell to zsh
chsh -s /opt/homebrew/bin/zsh

echo "Installing oh-my-zsh..."
# This env function is a hacky way to prevent a new shell from spawning when oh-my-zsh is done installing
env() {
  if ! [[ \$1 = zsh ]]; then /usr/bin/env \$@; fi
}
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
echo

# Setup Alacritty
git clone https://github.com/alacritty/alacritty.git ~/.config/alacritty
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
sudo tic -xe alacritty,alacritty-direct ~/.config/alacritty/extra/alacritty.info
defaults write org.alacritty AppleFontSmoothing -int 0

# Setup tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Stow
cd "$(dirname "$(readlink -f "$0")")/../config"
stow Aerospace --target $HOME
stow Alacritty --target $HOME
stow JetBrains --target $HOME
stow Karabiner --target $HOME
stow VSCode --target $HOME
stow assorted-cli --target $HOME
stow git --target $HOME
stow nvim --target $HOME
stow shells --target $HOME
stow tmux --target $HOME

echo "Installing elixir, erlang, node, python, and ruby..."
asdf plugin add elixir
asdf plugin add erlang
asdf plugin add nodejs
asdf plugin add python
asdf plugin add ruby
asdf install elixir 1.13.2
asdf install erlang 24.2.1
asdf install nodejs 16.13.1
asdf install python 3.10.0
asdf install ruby 3.1.0
asdf global elixir 1.13.2
asdf global erlang 24.2.1
asdf global nodejs 16.13.1
asdf global python 3.10.0
asdf global ruby 3.1.0
echo

echo "Installing tmuxifier..."
git clone https://github.com/jimeh/tmuxifier.git ~/.tmuxifier
echo

# Install fzf shell extensions
$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc
