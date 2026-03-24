#####################
# Cross-shell Setup #
#####################
source ~/.profile

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
if [[ -f "$HOME/.cargo/env" ]]; then
  . "$HOME/.cargo/env"
fi
