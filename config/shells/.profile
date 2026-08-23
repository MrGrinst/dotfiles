# This is a shared profile that will be sourced in all shell types

export HOMEBREW_PREFIX=/opt/homebrew

# Set vim as the default editor for the terminal
export EDITOR=nvim
export VISUAL=$EDITOR
export TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins"
export BAT_THEME="gruvbox-dark"

#############
# Pathmunge #
#############

# Function to prevent duplicate entries in path
pathmunge() {
  case ":${PATH}:" in
  *:"$1":*) ;;

  *)
    if [ "$2" = "after" ]; then
      PATH=$PATH:$1
    else
      PATH=$1:$PATH
    fi
    ;;
  esac
}

########
# Path #
########

if [ -x /usr/libexec/path_helper ]; then
  PATH=""
  eval $(/usr/libexec/path_helper -s)
fi

# Path configuration (this needs to be set before the version/package managers below)
pathmunge $HOME/Developer/dotfiles/bin
pathmunge $HOME/.local/bin
pathmunge $HOMEBREW_PREFIX/bin
pathmunge $HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin

############################
# Version/Package Managers #
############################

# Homebrew
export HOMEBREW_CASK_OPTS="--appdir=/Applications" # Tells homebrew cask where to install applications

# mise manages tool versions and non-secret project env ([env]); fnox provides secrets.
if [ -n "$ZSH_VERSION" ]; then
  _shell=zsh
elif [ -n "$BASH_VERSION" ]; then
  _shell=bash
else
  _shell=sh
fi

command -v mise >/dev/null 2>&1 && eval "$(mise activate "$_shell")"
command -v fnox >/dev/null 2>&1 && eval "$(fnox activate "$_shell")"
unset _shell

source ~/.aliases

export QMK_HOME="$HOME/Developer/qmk_firmware"
