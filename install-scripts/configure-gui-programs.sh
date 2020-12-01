#!/bin/bash

##########
# iTerm2 #
##########

echo "Configuring iTerm2..."
  # Make iTerm2 load from external config file
  defaults write com.googlecode.iterm2 "PrefsCustomFolder" -string "~/Developer/dotfiles/gui-config/iTerm2"
  defaults write com.googlecode.iterm2 "LoadPrefsFromCustomFolder" -bool true
echo


###############
# Hammerspoon #
###############

echo "Configuring Hammerspoon..."
  # Link init.lua file
  mkdir -p ~/.hammerspoon
  ln -s ~/Developer/dotfiles/gui-config/Hammerspoon/init.lua ~/.hammerspoon/init.lua
echo


##########
# Alfred #
##########

echo "Configuring Alfred..."
  defaults write com.runningwithcrayons.Alfred-Preferences-3 "syncfolder" -string "~/Developer/dotfiles/gui-config/Alfred"
echo


#############
# Spectacle #
#############

echo "Configuring Spectacle..."
  mkdir -p  "~/Library/Application Support/Spectacle"
  ln -s ~/Developer/dotfiles/gui-config/Spectacle/Shortcuts.json "~/Library/Application Support/Spectacle/Shortcuts.json"
echo
