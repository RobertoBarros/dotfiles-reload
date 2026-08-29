# Dotfiles para macOS

Configuração pessoal para preparar um Mac como ambiente de desenvolvimento, com foco em Ruby, JavaScript, Python e produtividade no terminal. O projeto centraliza preferências de shell, terminais, editor, Git e gerenciamento de janelas, permitindo recriar o ambiente com um único script.

> Este repositório contém preferências pessoais e deve ser revisado antes da instalação, principalmente a identidade do Git, a configuração SSH e os atalhos do AeroSpace.

## Atalhos rápidos

Nos atalhos do AeroSpace, `Caps` representa `Cmd + Option + Control` por meio do Hyperkey.

### Abrir aplicativos

| Atalho | Aplicativo/ação |
| --- | --- |
| `Caps+C` | Abre o Google Chrome |
| `Caps+F` | Abre o Finder no workspace atual |
| `Caps+G` | Abre o Gmail |
| `Caps+H` | Abre o ChatGPT |
| `Caps+K` | Abre o Slack |
| `Caps+L` | Abre `localhost:3000` em uma aba do Chrome |
| `Caps+M` | Abre o Google Meet |
| `Caps+S` | Abre o Spotify |
| `Caps+T` | Abre o cmux |
| `Caps+V` | Abre o Visual Studio Code |
| `Caps+W` | Abre o WhatsApp |
| `Caps+X` | Abre o X |
| `Caps+Y` | Abre o YouTube |

Aplicativos fechados abrem no workspace atual. Aplicativos já abertos ativam sua janela existente.

### AeroSpace — janelas e workspaces

| Atalho | Ação |
| --- | --- |
| `Caps+Setas` | Move o foco entre as janelas |
| `Caps+Shift+Setas` | Move a janela na direção escolhida |
| `F1` até `F10` | Vai para os workspaces 1 a 10 |
| `Caps+F1` até `Caps+F10` | Move a janela para o workspace escolhido e vai até ele |
| `Caps+N` | Move a janela para o primeiro workspace vazio e vai até ele |
| `Caps+Shift+N` | Vai para o primeiro workspace vazio |
| `Caps+[` / `Caps+]` | Vai para o workspace não vazio anterior/seguinte |
| `Caps+Tab` | Alterna entre o workspace atual e o anterior |
| `Caps+Shift+Tab` | Move o workspace para o próximo monitor |
| `Caps+,` / `Caps+/` | Usa layout accordion/tiles |
| `Caps+=` / `Caps+-` | Aumenta/diminui o tamanho da janela |
| `Caps+R` | Reorganiza a árvore de janelas |
| `Caps+Enter` | Ativa ou desativa tela cheia |
| `Caps+Shift+F` | Alterna entre janela flutuante e lado a lado |
| `Caps+Shift+E` | Entra no modo de serviço do AeroSpace |

A lista completa, incluindo os comandos do modo de serviço, está em [`aerospace/cheatsheet.md`](aerospace/cheatsheet.md).

### WezTerm

| Atalho | Ação |
| --- | --- |
| `Cmd+Option+←/→` | Alterna entre as abas |
| `Cmd+D` | Divide o painel horizontalmente |
| `Cmd+Shift+D` | Divide o painel verticalmente |
| `Shift+Setas` | Move o foco entre os painéis |
| `Cmd+W` | Fecha o painel atual sem confirmação |
| `Cmd+K` | Limpa o histórico e a área visível |
| `Cmd+F` | Pesquisa no terminal |

### cmux

| Atalho | Ação |
| --- | --- |
| `Cmd+Control+Setas` | Move o foco entre os painéis |
| `Cmd+Option+↑/↓` | Alterna entre as abas da barra lateral |
| `Cmd+Option+←/→` | Alterna entre as superfícies |

## O que o instalador faz

Ao executar [`install.sh`](install.sh), o script:

1. verifica se as dependências necessárias para o alvo escolhido estão disponíveis;
2. instala ferramentas de linha de comando, aplicativos e fontes pelo Homebrew;
3. instala e define versões globais de Ruby, Node.js, Yarn e Python pelo Mise;
4. instala a CLI `skills` pelo Mise e aplica globalmente ao Codex e ao Claude Code as skills listadas em [`skills.txt`](skills.txt);
5. altera preferências do macOS para reduzir animações e acelerar teclado, Dock e Finder;
6. instala as extensões listadas em [`visual-studio-code/extensions.txt`](visual-studio-code/extensions.txt);
7. cria links simbólicos entre este repositório e os arquivos de configuração no diretório pessoal;
8. reinicia a sessão atual do Zsh.

## Softwares instalados

### Ferramentas e aplicativos via Homebrew

| Grupo | Software | Objetivo |
| --- | --- | --- |
| Dependências de compilação | `openssl`, `libyaml`, `pkg-config` | Bibliotecas e metadados usados na compilação de runtimes e pacotes, especialmente Ruby |
| Terminal e navegação | `eza`, `yazi`, `fzf` | Listagem moderna de arquivos, gerenciador de arquivos no terminal e busca interativa |
| Git | `lazygit` | Interface de terminal para operações do Git |
| Zsh | `zsh-syntax-highlighting`, `zsh-autosuggestions` | Destaque de comandos e sugestões baseadas no histórico |
| Terminais | WezTerm e cmux | Emuladores/ambientes de terminal configurados pelo repositório |
| Gerenciamento de janelas | AeroSpace | Organização automática das janelas em layouts e workspaces |
| Atalhos | Hyperkey | Transforma uma tecla em `Cmd + Option + Control` para acionar os atalhos do AeroSpace |
| Barra de menus | Ice | Organização dos ícones da barra de menus do macOS |
| Fontes | Fira Code Nerd Font e JetBrains Mono Nerd Font | Fontes com ligaduras e ícones para editor e terminal |

### Ferramentas via Mise

O instalador configura globalmente as versões atuais disponíveis de:

- Ruby
- Node.js
- Yarn
- Python
- Skills CLI (`npm:skills`)

Como as versões não estão fixadas no repositório, uma instalação futura pode escolher versões mais novas do que uma instalação anterior.

### Skills de agentes

O arquivo [`skills.txt`](skills.txt) mantém as skills globais no formato `repositorio@skill`. Durante a instalação, cada entrada é aplicada de forma não interativa ao Codex e ao Claude Code. Para reproduzir o conjunto em outra máquina, basta executar o instalador normalmente.

### Visual Studio Code

São instaladas 35 extensões voltadas principalmente a Ruby/Rails, ERB, Stimulus, Tailwind CSS, JavaScript, ESLint, Prettier, TOML, Markdown, CSV, SQLite, depuração e colaboração. A relação completa e editável está em [`visual-studio-code/extensions.txt`](visual-studio-code/extensions.txt).

### Softwares configurados, mas não instalados pelo script

| Software | Como é usado |
| --- | --- |
| Oh My Zsh | Carrega o tema, plugins, aliases, autocomplete e destaque do shell |
| Visual Studio Code | Recebe configurações e extensões; o comando `code` é obrigatório |
| Mise | Gerencia as linguagens e ativa os runtimes no Zsh |
| Ghostty | Recebe tema, fonte e preferências por link simbólico |
| Google Chrome | É usado pelo script de abertura de abas e por atalhos do AeroSpace |
| ChatGPT, Slack, Spotify e WhatsApp | Possuem atalhos no AeroSpace |
| Gmail, Google Meet e YouTube | Os atalhos esperam aplicativos web instalados pelo Chrome |

## Pré-requisitos

- macOS com Zsh;
- acesso à internet;
- Git e as Command Line Tools da Apple;
- [Homebrew](https://brew.sh/);
- [Mise](https://mise.jdx.dev/);
- [Visual Studio Code](https://code.visualstudio.com/) com o comando `code` no `PATH`;
- [Oh My Zsh](https://ohmyz.sh/).

Uma forma de preparar as dependências é:

```bash
xcode-select --install

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install mise
brew install --cask visual-studio-code

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Confirme que os comandos necessários estão acessíveis antes de continuar:

```bash
brew --version
mise --version
code --version
```

## Instalação

Alguns atalhos do repositório usam o caminho fixo `~/code/dotfiles-reload`. Por isso, este é o local recomendado para o clone:

```bash
mkdir -p ~/code
git clone https://github.com/RobertoBarros/dotfiles-reload.git ~/code/dotfiles-reload
cd ~/code/dotfiles-reload
./install.sh
```

Sem argumentos, o instalador executa todas as etapas. Para executar somente uma delas, informe o alvo desejado:

```bash
./install.sh skills
```

Os alvos disponíveis são:

| Alvo | Ação |
| --- | --- |
| `all` | Executa a instalação completa; é o padrão quando nenhum alvo é informado |
| `brew` | Instala os pacotes e aplicativos do Homebrew |
| `mise` | Instala e configura Ruby, Node.js, Yarn e Python |
| `skills` | Instala a CLI `skills` e as skills globais de [`skills.txt`](skills.txt) |
| `macos` | Aplica as preferências do macOS |
| `vscode` | Instala as extensões do VS Code |
| `links` | Cria os links simbólicos das configurações |

Use `./install.sh help` para consultar essa lista no terminal.

Para usar outro diretório, ajuste antes os caminhos presentes em [`oh-my-zsh/aliases.sh`](oh-my-zsh/aliases.sh) e [`aerospace/aerospace.toml`](aerospace/aerospace.toml).

### Atenção antes de executar

Durante a criação dos links simbólicos, o instalador remove qualquer arquivo, diretório ou link que já exista nos destinos abaixo. Ele **não cria backup automático**. Faça uma cópia das configurações que deseja preservar e revise, em especial:

- [`gitconfig`](gitconfig), que contém nome e e-mail usados nos commits;
- [`ssh/config`](ssh/config), que define a chave `~/.ssh/id_ed25519` como identidade padrão;
- os atalhos e aplicativos definidos em [`aerospace/aerospace.toml`](aerospace/aerospace.toml).

## Configurações aplicadas

### Links simbólicos

Os links mantêm o repositório como fonte das configurações. Alterações feitas nos arquivos abaixo passam a valer diretamente nos respectivos aplicativos.

| Arquivo no repositório | Destino no macOS |
| --- | --- |
| `visual-studio-code/settings.json` | `~/Library/Application Support/Code/User/settings.json` |
| `oh-my-zsh/zshrc.sh` | `~/.zshrc` |
| `oh-my-zsh/aliases.sh` | `~/.aliases` |
| `wezterm/wezterm.lua` | `~/.wezterm.lua` |
| `cmux/cmux.json` | `~/.config/cmux/cmux.json` |
| `ghostty/config` | `~/.config/ghostty/config` |
| `aerospace/aerospace.toml` | `~/.aerospace.toml` |
| `gitconfig` | `~/.gitconfig` |
| `irbrc` | `~/.irbrc` |
| `rspec` | `~/.rspec` |
| `ssh/config` | `~/.ssh/config` |
### Docker Sandboxes

Na pasta de um projeto, o comando `sandbox` usa o nome dessa pasta como nome do sandbox e publica `localhost:3000`:

```bash
sandbox create codex
sandbox start
sandbox port 3001 # troca a porta publicada para localhost:3001
sandbox shell # abre um shell interativo dentro do sandbox
sandbox stop
sandbox remove
sandbox hunk # executa hunk diff --watch dentro do sandbox
```

### Preferências do macOS

O script reduz ou desativa animações globais, do Dock e do Finder, ativa a redução de movimento e diminui o intervalo de repetição do teclado. Algumas mudanças podem exigir encerrar a sessão ou reiniciar os aplicativos afetados.

### Shell e produtividade

O Zsh é configurado com Oh My Zsh, ativação automática do Mise, busca de histórico por prefixo, integração do `fzf` e aliases para Git, `eza`, `yazi`, servidor HTTP local e tarefas comuns de desenvolvimento.

O AeroSpace organiza aplicativos em workspaces numéricos e usa `Caps Lock` como Hyperkey (`Cmd + Option + Control`). Consulte todos os atalhos em [`aerospace/cheatsheet.md`](aerospace/cheatsheet.md).

## Estrutura do repositório

```text
.
├── aerospace/           # Gerenciador de janelas, atalhos e scripts auxiliares
├── cmux/                # Atalhos do cmux
├── ghostty/             # Tema e preferências do Ghostty
├── oh-my-zsh/           # Zsh, plugins, variáveis e aliases
├── ssh/                 # Configuração do cliente SSH
├── visual-studio-code/  # Settings, perfil alternativo e extensões
├── wezterm/             # Tema, fonte, panes e atalhos do WezTerm
├── gitconfig            # Preferências e aliases globais do Git
├── skills.txt           # Skills globais instaladas para os agentes
└── install.sh           # Provisionamento do ambiente
```

## Verificação após a instalação

```bash
brew list
mise ls
skills list --global
code --list-extensions
ls -l ~/.zshrc ~/.gitconfig ~/.aerospace.toml
```

Se o terminal não carregar as novas configurações automaticamente, abra uma nova janela ou execute `exec zsh`.
