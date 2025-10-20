# Load Homebrew environment
eval "$("$(/usr/bin/which brew)" shellenv 2>/dev/null || true)"

# Load mise environment
eval "$($(brew --prefix mise)/bin/mise activate zsh)"
