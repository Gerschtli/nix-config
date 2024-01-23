#!/usr/bin/env bash
set -euo pipefail

defaults write NSGlobalDomain AppleInterfaceStyle Dark
defaults write NSGlobalDomain KeyRepeat -int 3
defaults write NSGlobalDomain "com.apple.mouse.tapBehavior" -int 1
defaults write NSGlobalDomain "com.apple.swipescrolldirection" -bool false # disable natural scrolling
defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock "mru-spaces" -bool "false"
killall Dock

defaults write com.apple.spaces "spans-displays" -bool "false"
killall SystemUIServer

defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXPreferredViewStyle "Nlsv" # list view
defaults write com.apple.finder QuitMenuItem -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
killall Finder
