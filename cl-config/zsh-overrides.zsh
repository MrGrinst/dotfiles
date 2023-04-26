#!/bin/zsh

alias l='/bin/ls -G'
alias ls='ls -lhGFA'
alias buf='/usr/local/bin/buf'

bindkey "^[?" kill-region
bindkey "^[_" undefined-key

export ZSH_THEME_TERM_TAB_TITLE_IDLE=zsh
