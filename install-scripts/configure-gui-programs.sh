#!/bin/bash

##########
# iTerm2 #
##########

echo "Configuring iTerm2..."
# Make iTerm2 load from external config file
defaults write com.googlecode.iterm2 "PrefsCustomFolder" -string "~/Developer/dotfiles/gui-config/iTerm2"
defaults write com.googlecode.iterm2 "LoadPrefsFromCustomFolder" -bool true

# Install italics support for iTerm
tic ./italics-support/xterm-256color-italic.terminfo

# Add Meslo Nerd-Font
cd ~/Library/Fonts
curl -fLo "Meslo Regular Nerd Font.otf" https://github.com/ryanoasis/nerd-fonts/raw/0.9.0/patched-fonts/Meslo/L/complete/Meslo%20LG%20L%20Regular%20for%20Powerline%20Nerd%20Font%20Complete.otf
cd -
echo


##########
# Chrome #
##########

echo "Configuring Chrome..."
# Use the system-native print preview dialog
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome.canary DisablePrintPreview -bool true

# Expand the print dialog by default
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true
echo
