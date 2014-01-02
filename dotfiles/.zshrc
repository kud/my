# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Homebrew Cask
export HOMEBREW_CASK_OPTS=--appdir=/Applications

# Export MY
export MY=$HOME/my/

# Editor
export EDITOR='subl -w'

# Path
export PATH=/usr/local/opt/ruby/bin:/usr/local/share/npm/bin:/usr/local/lib/node_modules:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin

# Aliases
. ~/.aliases

# Android
export ANDROID_SDK_ROOT=/usr/local/Cellar/android-sdk/r20.0.1

# rbenv
# if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Increase opened files size
ulimit -n 1024

# Prefer British and use UTF-8
export LANG="en_GB"
export LC_ALL="en_GB.UTF-8"

# Java
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home

# Local
. ~/.zshrc_local
