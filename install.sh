#!/usr/bin/env zsh

# Fail fast and safely:
# -e : exit on any command failure
# -u : treat unset variables as errors
# -o pipefail : fail if any command in a pipeline fails
set -euo pipefail

# Libs and tools
brew install openssl libyaml pkg-config

# Ruby
mise use -g ruby@3.4



# Set faster key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# fonts
brew install --cask font-fira-code-nerd-font
brew install --cask font-jetbrains-mono-nerd-font


DOTFILES_ROOT="${DOTFILES_ROOT:-$PWD}"

# Visual Studio Code settings
xargs -n1 code --force --install-extension < "${DOTFILES_ROOT}/visual-studio-code/extensions.txt"

# VSCode settings symlink
SETTINGS_SRC="${DOTFILES_ROOT}/visual-studio-code/settings.json"
SETTINGS_DEST="$HOME/Library/Application Support/Code/User/settings.json"

if [[ ! -f "$SETTINGS_SRC" ]]; then
  echo "VSCode settings.json not found: $SETTINGS_SRC" >&2
  exit 1
fi

mkdir -p "$(dirname "$SETTINGS_DEST")"

if [[ -e "$SETTINGS_DEST" || -L "$SETTINGS_DEST" ]]; then
  rm -rf "$SETTINGS_DEST"
fi

ln -s "$SETTINGS_SRC" "$SETTINGS_DEST"

echo "Linked VSCode settings:"
echo "  $SETTINGS_DEST -> $SETTINGS_SRC"


# Paths
SRC="${DOTFILES_ROOT}/elgato-stream-deck/ProfilesV2"
DEST="$HOME/Library/Application Support/com.elgato.StreamDeck/ProfilesV2"

# Ensure source exists
if [[ ! -d "$SRC" ]]; then
  echo "Source not found: $SRC" >&2
  exit 1
fi

# Ensure destination parent directory exists
mkdir -p "$(dirname "$DEST")"

# Remove existing directory or symlink if present
if [[ -e "$DEST" || -L "$DEST" ]]; then
  rm -rf "$DEST"
fi

# Create new symlink
ln -s "$SRC" "$DEST"

echo "Linked:"
echo "  $DEST -> $SRC"
