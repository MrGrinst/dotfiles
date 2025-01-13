#!/bin/bash

if [[ ! -f ~/.ssh/id_dsa ]]; then
  echo "Generating machine's ssh key..."
  ssh-keygen -t ed25519 -C "kyle@grinsteadfam.com" -P "" -f ~/.ssh/id_ed25519
  echo
fi

# Change shell to zsh
chsh -s /opt/homebrew/bin/zsh

echo "Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
echo

# Setup tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
pip3 install libtmux

# Stow
rm ~/.zshrc
cd "$(dirname "$(readlink -f "$0")")/../config"
stow Aerospace --target $HOME
stow JetBrains --target $HOME
stow Karabiner --target $HOME
stow VSCode --target $HOME
stow assorted-cli --target $HOME
stow ghostty --target $HOME
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
asdf plugin add bun
asdf install elixir 1.17.3
asdf install erlang 27.1.2
asdf install nodejs 22.11.0
asdf install python 3.13.0
asdf install ruby 3.3.6
asdf install bun 1.1.38
asdf global elixir 1.17.3
asdf global erlang 27.1.2
asdf global nodejs 22.11.0
asdf global python 3.13.0
asdf global ruby 3.3.6
asdf global bun 1.1.38
echo

echo "Installing tmuxifier..."
git clone https://github.com/jimeh/tmuxifier.git ~/.tmuxifier
echo
