#####################
# Cross-shell Setup #
#####################
source ~/.profile

#############
# Oh-my-zsh #
#############

export TERM=alacritty

export ZSH=~/.oh-my-zsh
ZSH_THEME="refined"
plugins=(
  ansible
  asdf
  bun
  direnv
  docker
  docker-compose
  encode64
  gem
  gitfast
  httpie
  yarn
  z
)
DISABLE_UPDATE_PROMPT=true # Prevent oh-my-zsh from asking about updating
DISABLE_AUTO_UPDATE=true # Prevent oh-my-zsh from auto-updating
source $ZSH/oh-my-zsh.sh

export MAILCHECK=0 # Don't annoy me with "mail" messages
export KEYTIMEOUT=1 # Make sure escape doesn't cause issues

export COLORTERM=truecolor

# Max out history size
export HISTSIZE=10000000
export SAVEHIST=10000000

setopt INC_APPEND_HISTORY

# If you do a 'rm *', Zsh will give you a sanity check!
setopt RM_STAR_WAIT

#######
# FZF #
#######

source <(fzf --zsh)

# Set rg as the default source for fzf. Speedy!
export FZF_DEFAULT_COMMAND='rg --files'

# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

PS1=$'%{\033]133;A\033\\%}'$PS1

tmux-window-name() {
  ($TMUX_PLUGIN_MANAGER_PATH/tmux-window-name/scripts/rename_session_windows.py &)
}

# Allow hooking into zsh
autoload -U add-zsh-hook

add-zsh-hook chpwd tmux-window-name
