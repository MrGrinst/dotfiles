# This is a shared profile that will be sourced in all shell types

export HOMEBREW_PREFIX=/opt/homebrew

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
  eval `/usr/libexec/path_helper -s`
fi

export ANDROID_HOME=$HOME/Library/Android/sdk
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home

# Path configuration (this needs to be set before the version/package managers below)
pathmunge $ANDROID_HOME/platform-tools
pathmunge $ANDROID_HOME/emulator
pathmunge $HOME/Developer/dotfiles/bin
pathmunge $HOME/Developer/biblio-dotfiles/bin
pathmunge $HOME/.tmuxifier/bin
pathmunge /Applications/Postgres.app/Contents/Versions/14/bin
pathmunge /Applications/Postgres.app/Contents/Versions/13/bin
pathmunge $HOME/.local/bin
pathmunge $HOME/.config/nvim/plugged/vim-iced/bin
pathmunge $HOME/.krew/bin
pathmunge /usr/local/sbin
pathmunge /usr/local/opt/gnu-sed/libexec/gnubin
pathmunge $HOME/.k9s/plugins
pathmunge $HOME/Developer/breakdown-tool/bin
pathmunge $HOMEBREW_PREFIX/bin
pathmunge $HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin
pathmunge $HOMEBREW_PREFIX/opt/libpq/bin
pathmunge $HOMEBREW_PREFIX/opt/openjdk/bin
pathmunge $HOMEBREW_PREFIX/opt/openjdk@11/bin
pathmunge $HOME/.dotnet/tools
pathmunge $HOME/Developer/csharp-language-server/src/CSharpLanguageServer/bin/Debug/net8.0

############################
# Version/Package Managers #
############################

# Homebrew
export HOMEBREW_CASK_OPTS="--appdir=/Applications" # Tells homebrew cask where to install applications

# asdf
source $(brew --prefix asdf)/libexec/asdf.sh

# NPM
pathmunge $HOME/.npm-packages/bin

# OpenSSL
pathmunge /usr/local/opt/openssl@1.1/bin

# Go
pathmunge $HOME/go/bin

# Tmuxifier
if [[ -z "$TMUXIFIER" ]]; then
  eval "$(tmuxifier init -)"
fi

# Envman
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

source ~/.aliases

export QMK_HOME="~/Developer/qmk_firmware"
