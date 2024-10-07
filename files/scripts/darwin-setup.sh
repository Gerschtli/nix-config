#!/usr/bin/env bash
set -euo pipefail

# manually
# - install chrome, intellij, iterm2, docker, vscode, karabiner elements, homebrew
# - run ./darwin-defaults.sh
# - run commands below
# - iterm2 set UbuntuMono font, size 13, h 85, v 115, tango dark
# - disable keyboard shortcuts for "Input Sources" in system settings
# - enable keyboard shortcuts for Mission Control to switch to desktops
# - enable keyboard layout "German No Deadkeys" (might require logout"
# - Keyboard > Input Sources: Disable "Show Input menu in menu bar"
# - Trackpad: Enable Tap to Click
# - karabiner mapping:
#   - left_control -> left_command
#   - left_option -> left_control
#   - left_command -> left_option
#   - for internal keyboard:
#     - fn -> left_command
#     - left_control -> fn

brew tap homebrew/cask-fonts
brew install --cask homebrew/cask-fonts/font-ubuntu-mono-nerd-font
brew install koekeishiya/formulae/yabai
yabai --start-service
brew install koekeishiya/formulae/skhd
skhd --start-service
brew install --cask spaceid

brew tap hivemq/mqtt-cli
brew install mqtt-cli

brew install graphviz
