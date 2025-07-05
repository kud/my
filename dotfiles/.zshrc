# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set homebrew prefix depending on Intel or Apple Silicon
HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/usr/local}"


# Prezto (modularized)
[[ -f $HOME/.config/zsh/zprezto.zsh ]] && source $HOME/.config/zsh/zprezto.zsh

# Antidote
[[ -f $HOME/.config/zsh/antidote.zsh ]] && source $HOME/.config/zsh/antidote.zsh

# autojump
[ -f ${HOMEBREW_PREFIX}/etc/profile.d/autojump.sh ] && . ${HOMEBREW_PREFIX}/etc/profile.d/autojump.sh
autoload -U compinit && compinit

# zmv
autoload zmv

# z
[ -f ${HOMEBREW_PREFIX}/etc/profile.d/z.sh ] && . ${HOMEBREW_PREFIX}/etc/profile.d/z.sh

# functions
[[ -f $HOME/.config/zsh/functions.zsh ]] && source $HOME/.config/zsh/functions.zsh

# export MY
export MY=$HOME/my

# export TMP
export TMP=$HOME/__tmp

# export Sync Folder
export SYNC_FOLDER=$HOME/pCloud

# colours
export TERM=xterm-256color
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export CLICOLOR=1

# display
DISPLAY=:0.0; export DISPLAY

# british and utf-8
export LANG="en_GB"
export LC_ALL="en_GB.UTF-8"

# increase opened files size
ulimit -n 1024


# bindings
[[ -f $HOME/.config/zsh/bindings.zsh ]] && source $HOME/.config/zsh/bindings.zsh

# global variable
export GIT_EDITOR="nvim"
export VISUAL="code"
export EDITOR="nvim"

# aliases
[[ -f $HOME/.config/zsh/aliases.zsh ]] && source $HOME/.config/zsh/aliases.zsh


# Node.js
[[ -f $HOME/.config/zsh/node.zsh ]] && source $HOME/.config/zsh/node.zsh

# completions
[[ -f $HOME/.config/zsh/completions.zsh ]] && source $HOME/.config/zsh/completions.zsh

# android
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME


# Java
[[ -f $HOME/.config/zsh/java.zsh ]] && source $HOME/.config/zsh/java.zsh

# Python
[[ -f $HOME/.config/zsh/python.zsh ]] && source $HOME/.config/zsh/python.zsh

export LDFLAGS="-L${HOMEBREW_PREFIX}/opt/openssl/lib"
export CPPFLAGS="-I${HOMEBREW_PREFIX}/opt/openssl/include"

# homebrew cask
export HOMEBREW_CASK_OPTS=--appdir=/Applications

# babel
export BABEL_CACHE_PATH=/tmp/babel.cache.json

# ssl
export SSL_CERT_FILE=${HOMEBREW_PREFIX}/etc/openssl@3/cert.pem

# PATH
[[ -f $HOME/.config/zsh/path.zsh ]] && source $HOME/.config/zsh/path.zsh

# local config migration and sourcing
if [[ -f $HOME/.zshrc_local ]]; then
  echo "[zshrc] Migrating ~/.zshrc_local to ~/.config/zsh/local.zsh..."
  mkdir -p $HOME/.config/zsh
  mv $HOME/.zshrc_local $HOME/.config/zsh/local.zsh
  echo "[zshrc] Migration complete. Please remove this migration block from your .zshrc."
fi
[[ -f $HOME/.config/zsh/local.zsh ]] && source $HOME/.config/zsh/local.zsh

# add or override commands by via profiled ones
export PATH=$MY/profiles/$OS_PROFILE/bin/_:$PATH

# fzf
source <(fzf --zsh)

# ruby
eval "$(frum init)"

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/p10k.zsh.
# Should be always the last line
[[ ! -f ~/.config/zsh/p10k.zsh ]] || source ~/.config/zsh/p10k.zsh

# For some strange reason, `fnm` needs to be at the end in order to view the local version in the shell.
eval "$(fnm env --use-on-cd)" > /dev/null 2>&1
