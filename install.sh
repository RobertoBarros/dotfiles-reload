#!/usr/bin/env zsh

# Fail fast and safely
set -euo pipefail

# ---------- UI / logs ----------
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'; RESET=$'\033[0m'
  RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; BLUE=$'\033[34m'
else
  BOLD=""; RESET=""; RED=""; GREEN=""; YELLOW=""; BLUE=""
fi

ICON_INFO="ℹ️ "
ICON_OK="✅ "
ICON_WARN="⚠️ "
ICON_ERR="❌ "
ICON_LINK="🔗 "
ICON_RUN="🚀 "
ICON_STEP="▶️ "

log()       { printf "%s%s%s\n"        "$ICON_INFO" "$*" "$RESET"; }
log_step()  { printf "%s%s%s%s\n"      "$BLUE$BOLD" "$ICON_STEP" "$*..." "$RESET"; }
log_ok()    { printf "%s%s%s\n"        "$GREEN$BOLD" "$ICON_OK$*" "$RESET"; }
log_warn()  { printf "%s%s%s\n"        "$YELLOW$BOLD" "$ICON_WARN$*" "$RESET"; }
log_err()   { printf "%s%s%s\n"        "$RED$BOLD" "$ICON_ERR$*" "$RESET"; }

die() { log_err "$*"; exit 1; }

# Section title
section() {
  local title="$1"
  printf "\n%s%s%s\n" "$BOLD" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "$RESET"
  printf "%s%s %s%s\n" "$BOLD" "$ICON_RUN" "$title" "$RESET"
  printf "%s%s%s\n\n" "$BOLD" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "$RESET"
}

TRAPERR() { log_err "Unexpected failure. Line ${LINENO}"; }

# ---------- helpers ----------
require() {
  local bin="$1"
  if command -v "$bin" >/dev/null 2>&1; then
    log_ok "dependency found: $bin"
  else
    die "missing dependency: $bin"
  fi
}

link_one() {
  local src="$1" dest="$2"
  log_step "linking: $dest"
  [[ -e "$src" || -L "$src" ]] || die "source not found: $src"

  mkdir -p "$(dirname "$dest")"

  if [[ -e "$dest" || -L "$dest" ]]; then
    log_warn "removing existing: $dest"
    rm -rf "$dest"
  fi

  ln -s "$src" "$dest"
  printf "%s%s%s -> %s%s\n" "$GREEN$BOLD" "$ICON_LINK" "$dest" "$src" "$RESET"
}

install_brew_pkgs() {
  section "Homebrew packages"
  brew install openssl libyaml pkg-config
  brew install eza yazi fzf
  brew install zsh-syntax-highlighting zsh-autosuggestions
  brew install --cask font-fira-code-nerd-font
  brew install --cask font-jetbrains-mono-nerd-font
  brew install --cask jordanbaird-ice
  brew install --cask wezterm
  brew tap FelixKratz/formulae # JankyBorders for aerospace
  brew install borders
  brew install --cask nikitabobko/tap/aerospace
  log_ok "brew packages installed"
}

configure_mise() {
  section "Mise toolchains"
  mise settings add idiomatic_version_file_enable_tools ruby
  mise use -g ruby
  mise use -g node
  mise use -g yarn
  mise use -g python
  log_ok "mise configured"
}

set_macos_defaults() {
  section "macOS defaults"
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
  log_ok "macOS defaults applied"
}

install_vscode_extensions() {
  section "VS Code extensions"
  local list="${DOTFILES_ROOT}/visual-studio-code/extensions.txt"
  [[ -f "$list" ]] || die "VSCode extensions.txt not found: $list"
  xargs -n1 code --force --install-extension < "$list"
  log_ok "VS Code extensions installed"
}

link_batch() {
  section "Symlinks"
  local total=${#SYMLINKS[@]}
  local i=1
  local spec src dest
  for spec in "${SYMLINKS[@]}"; do
    IFS=$':' read -r src dest <<< "$spec"
    printf "%s%s[%d/%d]%s %s\n" "$BOLD" "$ICON_STEP" "$i" "$total" "$RESET" "$dest"
    link_one "$src" "$dest"
    (( i++ ))
  done
  log_ok "symlink creation completed ($total)"
}

# ---------- main ----------
section "Checking dependencies"
require defaults
require brew
require mise
require xargs
require code

DOTFILES_ROOT="${DOTFILES_ROOT:-$PWD}"
log "DOTFILES_ROOT: $DOTFILES_ROOT"

install_brew_pkgs
configure_mise
set_macos_defaults
install_vscode_extensions

# Declare symlinks here. Format: "SRC:DEST"
SYMLINKS=(
  "${DOTFILES_ROOT}/visual-studio-code/settings.json:$HOME/Library/Application Support/Code/User/settings.json"
  "${DOTFILES_ROOT}/elgato-stream-deck/ProfilesV2:$HOME/Library/Application Support/com.elgato.StreamDeck/ProfilesV2"
  "${DOTFILES_ROOT}/oh-my-zsh/zprofile.sh:$HOME/.zprofile"
  "${DOTFILES_ROOT}/oh-my-zsh/zshrc.sh:$HOME/.zshrc"
  "${DOTFILES_ROOT}/oh-my-zsh/aliases.sh:$HOME/.aliases"
  "${DOTFILES_ROOT}/wezterm/wezterm.lua:$HOME/.wezterm.lua"
  "${DOTFILES_ROOT}/aerospace/aerospace.toml:$HOME/.aerospace.toml"
  "${DOTFILES_ROOT}/gitconfig:$HOME/.gitconfig"
  "${DOTFILES_ROOT}/irbrc:$HOME/.irbrc"
  "${DOTFILES_ROOT}/rspec:$HOME/.rspec"
)

link_batch

section "Restarting shell"
log_step "exec zsh"
exec zsh
