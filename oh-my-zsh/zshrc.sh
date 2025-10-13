ZSH="$HOME/.oh-my-zsh"

plugins=(
  git gitfast last-working-dir common-aliases
  history-substring-search
  aliases
)

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source <(fzf --zsh)

ZSH_THEME="robbyrussell"

ZSH_DISABLE_COMPFIX=true # to avoid the message "compinit: insecure directories" when using brew

source "$ZSH/oh-my-zsh.sh"


##### 1) Variáveis de ambiente gerais  #################################################
export HOMEBREW_NO_ANALYTICS=1
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export BUNDLER_EDITOR=code
export EDITOR=code
export THOR_MERGE="code --wait"
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES # Problema da gem blazer https://stackoverflow.com/a/53404317


##### 3) Caminhos (PATH)  ##############################################################
export PATH="\
./bin:\
./node_modules/.bin:\
/opt/homebrew/opt/postgresql@18/bin:\
$PATH"


##### 4) Aliases  ##############################################
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"
