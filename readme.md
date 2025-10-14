# Dotfiles Setup Script

## Sobre

Script para provisionar um ambiente de desenvolvimento no macOS: instala pacotes via Homebrew, configura Mise, aplica defaults do macOS, instala extensões do VS Code e cria symlinks dos dotfiles.

## Pré-requisitos

- macOS e zsh
- oh-my-zsh: https://ohmyz.sh
- Homebrew: https://brew.sh
- Mise: https://mise.jdx.dev
- Visual Studio Code

## Instalação e uso

```bash
git clone https://github.com/RobertoBarros/dotfiles-reload.git ~/.dotfiles-reload
cd ~/.dotfiles-reload
chmod +x install.sh
./install.sh
```

O script:

- Verifica dependências
- Instala pacotes Homebrew (CLI e casks)
- Configura toolchains via Mise
- Aplica defaults do macOS
- Instala extensões do VS Code a partir de `visual-studio-code/extensions.txt`
- Cria symlinks para zsh, WezTerm, VS Code, Aerospace e Stream Deck

## Symlinks criados

| Origem (`$DOTFILES_ROOT`)        | Destino (`$HOME`)                                              |
| -------------------------------- | -------------------------------------------------------------- |
| visual-studio-code/settings.json | ~/Library/Application Support/Code/User/settings.json          |
| elgato-stream-deck/ProfilesV2    | ~/Library/Application Support/com.elgato.StreamDeck/ProfilesV2 |
| oh-my-zsh/zprofile.sh            | ~/.zprofile                                                    |
| oh-my-zsh/zshrc.sh               | ~/.zshrc                                                       |
| oh-my-zsh/aliases.sh             | ~/.aliases                                                     |
| wezterm/wezterm.lua              | ~/.wezterm.lua                                                 |
| aerospace/aerospace.toml         | ~/.aerospace.toml                                              |
