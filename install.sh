#!/usr/bin/env zsh

# Fail fast and safely:
# -e : exit on any command failure
# -u : treat unset variables as errors
# -o pipefail : fail if any command in a pipeline fails
set -euo pipefail

# Paths
DOTFILES_ROOT="${DOTFILES_ROOT:-$PWD}"
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
