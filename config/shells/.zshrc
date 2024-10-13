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
plugins=(gitfast brew npm z docker ansible docker-compose gem yarn httpie encode64 asdf)
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

# Attempt to fix file-limit issues. Probably doesn't work?
ulimit -S -n 9000

# Allow hooking into zsh
autoload -U add-zsh-hook

###########
# Aliases #
###########

alias sudo='sudo '
alias vim='nvim'
alias vi='nvim'
alias launchctl='reattach-to-user-namespace launchctl' # Fix tmux copy/paste
alias gs='git status'
alias gl='git latest'
alias gc='git commit -a'
alias gp='git push'
alias ghp='gh_push'
alias gb='git checkout $(git for-each-ref --sort=-committerdate refs/heads/ --format="%(refname:short)" | fzf)'
alias gr='if git rev-parse --quiet --verify master; then; git pull origin master --rebase; else; git pull origin main --rebase; fi'
alias ga='git commit --amend --no-verify --no-edit'
alias gae='git commit --amend --no-verify'
alias gap='git add . && git commit --amend --no-verify --no-edit && git push -f'
alias gd='git diff'
alias gdh='vim -c "DiffviewOpen"'
alias gyc="git rev-parse HEAD | tr -d '\n' | pbcopy"
alias git-clean-branches="git remote update origin --prune; git branch -r | awk -F/ '{print $2}' > remote-branches; git branch | awk 'NF{print $1}' > local-branches; grep -Fvxf remote-branches local-branches | xargs git branch -D; rm remote-branches local-branches"
alias base64='encode64'
alias todo='vim ~/.todo.md'
alias qr='f() { qrencode -s 6 -l H -o ~/Downloads/qr.png $1; open ~/Downloads/qr.png; }; f'
function vim-edit-changes() {
  if [[ -n "$(git diff --stat --name-only --relative --diff-filter=ACMRTUX ${1:-HEAD})" ]]; then
    vim $(git diff --stat --name-only --relative --diff-filter=ACMRTUX ${1:-HEAD})
  else
    echo "No changes"
  fi
}
function convert_pdf_to_remarkable_template() {
  convert -density 300 "$1" -trim -geometry 1404x "$2"
}
alias vim-fix-conflicts='vim $(git diff --name-only | sort -u)'

imv() {
  local src dst
  for src; do
    [[ -e $src ]] || { print -u2 "$src does not exist"; continue }
    dst=$src
    vared dst
    [[ $src != $dst ]] && mkdir -p $dst:h && mv -n $src $dst
  done
}

######################
# Additional Plugins #
######################

  #######
  # FZF #
  #######

  source <(fzf --zsh)

  # Re-bind CTRL-T to do the same as **<Tab>
  function _ctrl_t {
    if [[ "$BUFFER" == "" ]]; then
      fzf-file-widget
      file="${BUFFER%?}"
      if [[ -n "$file" ]]; then
        LBUFFER="vim $file"
        zle reset-prompt
        zle accept-line
      fi
    else
      LBUFFER="$LBUFFER**"
      zle reset-prompt
      fzf-completion
    fi
  }
  zle -N _ctrl_t
  bindkey '^T' _ctrl_t

  # Set rg as the default source for fzf. Speedy!
  export FZF_DEFAULT_COMMAND='rg --files'

  # To apply the command to CTRL-T as well
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

  export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

###############
# Local zshrc #
###############

if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi

##############################################
# Directory-specific zsh config and env vars #
##############################################

function iteratively_source_config_files() {
  source ~/.profile
  current_dir=$(pwd -P)
  level=$(echo $current_dir | tr -cd '/' | wc -c | xargs)
  if [[ $level -gt 2 ]]; then
    for i in {$(($level-3))..0}; do
      if [[ $i == "0" ]]; then
        dotdots=""
      else
        dotdots=$(printf '/..%.0s' {1..$i})
      fi
      zsh_config_file="$current_dir$dotdots/.zsh_config"
      exports_file="$current_dir$dotdots/.exports.env"
      if [[ -r $zsh_config_file ]]; then
        source $zsh_config_file
      fi
      if [[ -r $exports_file ]]; then
        source $exports_file
      fi
    done
  fi
}

function my_chpwd() {
  source ~/.profile
  iteratively_source_config_files
}

eval "$(direnv hook zsh)"
iteratively_source_config_files
add-zsh-hook chpwd my_chpwd

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# bun completions
[ -s "/Users/kylegrinstead/.bun/_bun" ] && source "/Users/kylegrinstead/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

PS1=$'%{\033]133;A\033\\%}'$PS1

tmux-window-name() {
  ($TMUX_PLUGIN_MANAGER_PATH/tmux-window-name/scripts/rename_session_windows.py &)
}

add-zsh-hook chpwd tmux-window-name
