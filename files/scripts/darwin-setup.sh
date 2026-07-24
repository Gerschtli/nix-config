#!/usr/bin/env bash
set -euo pipefail

# manually
# - install chrome, intellij, iterm2, docker, vscode, karabiner elements, homebrew
# - run ./darwin-defaults.sh
# - run commands below
# - iterm2 set UbuntuMono font, size 13, h 85, v 115, tango dark
# - enable keyboard shortcuts for Mission Control to switch to desktops
# - enable keyboard shortcuts option "Use F1. F2, etc. keys as standard function keys" to prevent F6 to be mapped by the OS
# - enable keyboard layout "German No Deadkeys" (might require logout"
# - Keyboard > Repeat rates set to max values
# - Keyboard > Input Sources: Disable "Show Input menu in menu bar"
# - disable apps in "Menu Bar" settings
# - karabiner mapping:
#   - left_control -> left_command
#   - left_option -> left_control
#   - left_command -> left_option
#   - for internal keyboard:
#     - fn -> left_command
#     - left_control -> fn
#     - grave_accent_and_tilde -> non_us_backslash
#     - non_us_backslash -> grave_accent_and_tilde
# - alt tab:
#   - option+tab
#   - show windows from Spaces: Visible Spaces
#   - Show windows from screens: Screen showing AltTab

brew install --cask font-ubuntu-mono-nerd-font

brew trust --formula koekeishiya/formulae/yabai
brew install koekeishiya/formulae/yabai
#yabai --start-service

brew trust --formula koekeishiya/formulae/skhd
brew install koekeishiya/formulae/skhd
#skhd --start-service

brew install --cask spaceid
brew install --cask alt-tab
brew install --cask hiddenbar

brew tap hivemq/mqtt-cli
brew trust hivemq/mqtt-cli
brew install mqtt-cli

brew install graphviz
brew install trivy

brew tap anchore/grype
brew trust anchore/grype
brew install --cask grype
