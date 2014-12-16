# prezto
# if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
#   source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
# fi

# pure
autoload -U promptinit && promptinit
prompt pure

# export MY
export MY=$HOME/my

# colours
export TERM=xterm-256color
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export CLICOLOR=1

# display
DISPLAY=:0.0; export DISPLAY

# path
export PATH=$HOME/my/bin:/usr/local/opt/ruby/bin:/usr/local/share/npm/bin:/usr/local/lib/node_modules:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin:$HOME/my/bin/shims

# british and utf-8
export LANG="en_GB"
export LC_ALL="en_GB.UTF-8"

# increase opened files size
ulimit -n 1024

# bind
bindkey '^R' history-incremental-search-backward

# global variable
export FIREFOXNIGHTLY_BIN="/Applications/FirefoxNightly.app/Contents/MacOS/firefox"
export BROWSER=$FIREFOXNIGHTLY_BIN
export EDITOR='subl -w'

# aliases
. ~/.aliases

# npm
export NODE_PATH=/usr/local/share/npm/lib/node_modules

# android
export ANDROID_HOME=/usr/local/opt/android-sdk

# java
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home

# python
export PYTHONPATH=/usr/local/lib/python2.7/site-packages

# homebrew cask
export HOMEBREW_CASK_OPTS=--appdir=/Applications

# hightlight
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# local
. ~/.zshrc_local
