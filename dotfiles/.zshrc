# prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# change prompt
prompt_context() {
  # local user=`whoami`

  # if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CONNECTION" ]]; then
  #   prompt_segment $PRIMARY_FG default " %(!.%{%F{yellow}%}.)$user@%m "
  # fi

  prompt_segment $PRIMARY_FG default  "  🌈  "
}

prompt_dir() {
  prompt_segment blue $PRIMARY_FG ' %c '
}

# autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

# functions
## set the tab title to current dir
# function precmd() {
#   echo -ne "\e]1;${PWD##*/}\a"
# }

## create a folder and go in it
function mcd() {
  mkdir -p "$1" && cd "$1";
}

# export MY
export MY=$HOME/my

# export TMP
export TMP=$HOME/__tmp

# colours
export TERM=xterm-256color
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export CLICOLOR=1

# display
DISPLAY=:0.0; export DISPLAY

# path
export PATH=$HOME/my/bin/_:$HOME/my/bin/git:/usr/local/opt/ruby/bin:/usr/local/share/npm/bin:/usr/local/lib/node_modules:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin:$HOME/my/bin/shims

# british and utf-8
export LANG="en_GB"
export LC_ALL="en_GB.UTF-8"

# increase opened files size
ulimit -n 1024

# bind
bindkey '^R' history-incremental-search-backward

# global variable
# export FIREFOXNIGHTLY_BIN="/Applications/FirefoxNightly.app/Contents/MacOS/firefox"
# export BROWSER=$FIREFOXNIGHTLY_BIN # bug with python
export EDITOR='subl'

# aliases
. ~/.aliases

# node
export NODE_PATH=/usr/local/share/npm/lib/node_modules

# android
export ANDROID_HOME=/usr/local/opt/android-sdk

# java
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home

# python
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

# homebrew cask
export HOMEBREW_CASK_OPTS=--appdir=/Applications

# local
. ~/.zshrc_local

export PATH=$HOME/my/profiles/$OS_PROFILE/bin:$PATH
