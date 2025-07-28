# zsh settings
# unsetopt AUTO_CD

# Sublime
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"

# VSCode
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# pytest
export PYTEST_ADDOPTS="--color=yes"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# pipenv
export PIPENV_PYTHON="$PYENV_ROOT/shims/python"

# Homebrew shell completion
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi

# Shell integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

function arm() {
  echo "Setting architecture to arm64"
  env /usr/bin/arch -arm64 /bin/zsh --login
}

function intel() {
  echo "Setting architecture to x86_64"
  env /usr/bin/arch -x86_64 /bin/zsh --login
}

function xmove() {
  LENGTH=${1:-1}
  DELAY=${2:-5}

  MOVEMENTS=(
    "m:+$LENGTH,+0"
    "m:+0,+$LENGTH"
    "m:-$LENGTH,+0"
    "m:+0,-$LENGTH"
  )

  while true; do
    for MOVEMENT in "${MOVEMENTS[@]}"; do
      echo "cliclick $MOVEMENT"
      cliclick $MOVEMENT
    done

    echo "sleep $DELAY"
    sleep $DELAY
  done
}

function gcommit() {
  local BRANCH_NAME=$(git symbolic-ref --short HEAD 2>/dev/null)
  local JIRA_TICKET=$(echo $BRANCH_NAME | grep -oE "[A-Z]+-[0-9]+")
  local args=()
  local next_is_msg=0

  for arg in "$@"; do
    if [[ $next_is_msg -eq 1 ]]; then
      if [ ! -z "$JIRA_TICKET" ] && [[ ! "$arg" =~ $JIRA_TICKET ]]; then
        arg="$JIRA_TICKET: $arg"
      fi
      args+=("$arg")
      next_is_msg=0
    elif [[ "$arg" == "-m" || "$arg" == "--message" ]]; then
      args+=("$arg")
      next_is_msg=1
    else
      args+=("$arg")
    fi
  done

  echo "git commit ${args[@]}"
  git commit "${args[@]}"
}

function gpushdt() {
  git add .
  git commit -m "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  git push $*
}

source "/opt/homebrew/share/antigen/antigen.zsh"

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
# antigen bundle git
# antigen bundle heroku
# antigen bundle pip
# antigen bundle lein
antigen bundle command-not-found

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# Honors the original bright colors of your shell
antigen bundle chriskempson/base16-shell

# Plugin for installing, updating and loading nvm
export NVM_COMPLETION=true
export NVM_LAZY_LOAD=true
export NVM_AUTO_USE=true
antigen bundle lukechilds/zsh-nvm

# Type git open to open the repo website
antigen bundle paulirish/git-open

# Load the theme.
antigen theme robbyrussell

# Additional completions for Zsh
antigen bundle zsh-users/zsh-completions

# 256 Color
antigen bundle chrissicool/zsh-256color

# Tell Antigen that you're done.
antigen apply
