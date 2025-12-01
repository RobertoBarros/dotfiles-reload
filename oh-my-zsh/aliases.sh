# Get External IP / Internet Speed
alias myip="curl https://ipinfo.io/json" # or /ip for plain-text ip
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"

# Quickly serve the current directory as HTTP
alias serve='ruby -run -e httpd . -p 8000' # Or python -m SimpleHTTPServer :)

alias gs='git status'
alias gitclean='git branch --merged | egrep -v "(^\*|master|main|dev)" | xargs git branch -d && git remote prune origin'

# https://github.com/eza-community/eza
alias l='eza -l --icons --no-permissions --no-user --git -F'
alias ll='eza -la --icons --no-permissions --no-user --git -F '
alias lll='yazi'

alias remove-node-modules="find . -name "node_modules" -type d -prune -exec rm -rf '{}' +"

# Alterar configuração do VSCode
alias vsconf="$HOME/code/dotfiles-reload/visual-studio-code/switch_vscode_config.sh"

# Muda o título da tab do WezTerm
tab() {
  wezterm cli set-tab-title "$*"
}

# Terminate all connections to the current Rails database
dbkill() {
  local dbname
  dbname=$(rails runner "puts ActiveRecord::Base.connection_db_config.database" 2>/dev/null)

  if [ -z "$dbname" ]; then
    echo "Could not detect database name. Are you in a Rails app folder?"
    return 1
  fi

  psql -d postgres -c "SELECT pg_terminate_backend(pid)
                       FROM pg_stat_activity
                       WHERE datname='${dbname}'
                         AND pid <> pg_backend_pid();"
}

unalias lt # para usar o localtunnel
