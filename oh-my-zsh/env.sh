#
# Shared shell environment bootstrap.
# Loaded from both login shells (.zprofile) and interactive shells (.zshrc)
# so terminals with different startup modes can still find brew and mise.
#
[[ -n ${DOTFILES_ENV_LOADED:-} ]] && return
export DOTFILES_ENV_LOADED=1

for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  [[ -x "$brew_bin" ]] && eval "$("$brew_bin" shellenv)" && break
done

command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"
