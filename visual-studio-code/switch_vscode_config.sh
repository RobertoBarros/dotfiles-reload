#!/usr/bin/env zsh
set -euo pipefail

DOTFILES="$HOME/code/dotfiles-reload/visual-studio-code"
VSCODE_CONFIG="$HOME/Library/Application Support/Code/User/settings.json"

if [[ "${1:-default}" == "lewagon" ]]; then
  ln -sf "$DOTFILES/settings_lewagon.json" "$VSCODE_CONFIG"
  echo "VSCode settings switched to lewagon"
else
  ln -sf "$DOTFILES/settings.json" "$VSCODE_CONFIG"
  echo "VSCode settings switched to default"
fi
