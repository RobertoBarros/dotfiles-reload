# Load Homebrew environment
eval "$("$(/usr/bin/which brew)" shellenv 2>/dev/null || true)"

# Load mise environment
eval "$(~/.local/bin/mise activate bash)"
