#!/bin/zsh

alias l='/bin/ls -G'
alias ls='ls -lhGFA'

bindkey "^h" beginning-of-line
bindkey "^l" end-of-line
bindkey "^[?" kill-region
bindkey "^[_" undefined-key

