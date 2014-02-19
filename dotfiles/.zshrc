# source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# homebrew cask
export HOMEBREW_CASK_OPTS=--appdir=/Applications

# export MY
export MY=$HOME/my/

# editor
export EDITOR='subl -w'

# path
export PATH=/usr/texbin:/usr/local/opt/ruby/bin:/usr/local/share/npm/bin:/usr/local/lib/node_modules:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin

# Aliases
. ~/.aliases

# global variable
export AURORA_BIN="/Applications/FirefoxAurora.app/Contents/MacOS/firefox"
export BROWSER=$AURORA_BIN
export EDITOR="subl"
export SVN_EDITOR="vim"

# colours
export TERM=xterm-256color
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export CLICOLOR=1

# display
DISPLAY=:0.0; export DISPLAY

# android
export ANDROID_HOME=/usr/local/opt/android-sdk

# rbenv
# if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# increase opened files size
ulimit -n 1024

# prefer British and use UTF-8
export LANG="en_GB"
export LC_ALL="en_GB.UTF-8"

# java
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home

# local
. ~/.zshrc_local
