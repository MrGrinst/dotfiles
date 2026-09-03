#####################
# Cross-shell Setup #
#####################
if [[ ! -o login ]]; then
  source ~/.profile
  [ -f ~/.profile.local ] && source ~/.profile.local
fi

##############
# Completion #
##############

# Pick up Homebrew-installed completions (gh, docker, etc.)
if command -v brew >/dev/null 2>&1; then
  fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi

autoload -Uz compinit && compinit -C

# Fuzzy matching: try exact, then case-insensitive, then match a typed
# fragment anywhere in the candidate (so "cfg" completes "config", "load"
# completes "download"). Each rule is a fallback for the previous one.
zstyle ':completion:*' matcher-list '' \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

##########
# Prompt #
##########

command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

############
# Keybinds #
############

# Force the emacs keymap. $EDITOR is nvim, so zsh would otherwise select the
# vi-insert keymap and drop the emacs word-motion and line-editing bindings.
bindkey -e

bindkey "^[?" kill-region
bindkey "^[_" undefined-key

# Word motion and delete-word. Karabiner maps Cmd+n / Cmd+m / Cmd+Backspace to
# Alt+Left / Alt+Right / Alt+Backspace; bind the CSI sequences terminals send for
# Alt- and Ctrl-Arrow (the meta ^[b/^[f/^[^? forms are emacs defaults already).
bindkey "^[[1;3D" backward-word
bindkey "^[[1;3C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[^?"    backward-kill-word

# Treat - and _ as word boundaries so word motion and kill stop at each segment
# (foo-bar_baz -> foo | bar | baz). zsh's default WORDCHARS counts both as word
# characters, so drop them from the list.
WORDCHARS='*?.[]~=/&;!#$%^(){}<>'

export KEYTIMEOUT=1 # Make sure escape doesn't cause issues
stty -ixon # Let Ctrl-S/Ctrl-Q reach tmux and other terminal apps.

export COLORTERM=truecolor

# Max out history size
export HISTSIZE=10000000
export SAVEHIST=10000000

setopt INC_APPEND_HISTORY

# Skip duplicates: don't store a command that duplicates the previous one, and
# don't surface duplicates when searching/navigating history.
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS

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

eval "$(zoxide init zsh)"

###########
# Plugins #
###########

# Up/Down search history for entries matching the substring already typed.
# Bindings must come after the plugin is sourced.
hss="${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
if [ -r "$hss" ]; then
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='underline'
  source "$hss"
  for key in "$terminfo[kcuu1]" '^[[A' '^[OA'; do bindkey "$key" history-substring-search-up; done
  for key in "$terminfo[kcud1]" '^[[B' '^[OB'; do bindkey "$key" history-substring-search-down; done
fi
unset hss
