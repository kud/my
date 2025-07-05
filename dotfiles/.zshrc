# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set homebrew prefix depending on Intel or Apple Silicon
HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/usr/local}"

# prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

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

# node
export NODE_PATH=${HOMEBREW_PREFIX}/lib/node_modules


# completions
[[ -f $HOME/.config/zsh/completions.zsh ]] && source $HOME/.config/zsh/completions.zsh


# android
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME

# java
export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"

# python
if which pyenv > /dev/null; then eval "$(pyenv init --path)"; fi
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

export LDFLAGS="-L${HOMEBREW_PREFIX}/opt/openssl/lib"
export CPPFLAGS="-I${HOMEBREW_PREFIX}/opt/openssl/include"

# homebrew cask
export HOMEBREW_CASK_OPTS=--appdir=/Applications

# babel
export BABEL_CACHE_PATH=/tmp/babel.cache.json

# ssl
export SSL_CERT_FILE=${HOMEBREW_PREFIX}/etc/openssl@3/cert.pem

# PATH - must be in the end
export PATH=${HOMEBREW_PREFIX}/sbin:$PATH # brew
export PATH=${HOMEBREW_PREFIX}/Cellar/:$PATH # brew
export PATH=${HOMEBREW_PREFIX}/opt/curl/bin:$PATH # curl
export PATH=${HOMEBREW_PREFIX}/opt/ruby/bin:$PATH # ruby
export PATH=${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin:$PATH # gnu-sed
export PATH=${HOMEBREW_PREFIX}/lib/node_modules:$PATH # npm
export PATH=$PATH:$ANDROID_HOME/emulator # android emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools # android platform-tools
export PATH=$HOME/.console-ninja/.bin:$PATH # console-ninja

export PATH=$MY/bin/_:$PATH # own commands

export PATH=$PATH:$MY/bin/shims # add commands to open applications

# local
. ~/.zshrc_local

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
