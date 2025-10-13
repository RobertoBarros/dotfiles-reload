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

# Muda o título da tab do WezTerm
tab() {
  wezterm cli set-tab-title "$*"
}

unalias lt # para usar o localtunnel
