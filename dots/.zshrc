# zsh settings
unsetopt AUTO_CD

# Sublime
export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"

# VSCode
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# pytest
export PYTEST_ADDOPTS="--color=yes"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PIPENV_PYTHON="$PYENV_ROOT/shims/python"
eval "$(pyenv init -)"

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
