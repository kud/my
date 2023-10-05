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

# antibody
source <(antibody init)

antibody bundle mtxr/zsh-change-case
antibody bundle bigH/git-fuzzy path:bin kind:path
antibody bundle unixorn/git-extra-commands
antibody bundle marlonrichert/zsh-autocomplete


# # change prompt
# prompt_context() {
#   # local user=`whoami`

#   # if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CONNECTION" ]]; then
#   #   prompt_segment $PRIMARY_FG default " %(!.%{%F{yellow}%}.)$user@%m "
#   # fi

#   prompt_segment $PRIMARY_FG default  ""
# }

# prompt_dir() {
#   prompt_segment blue $PRIMARY_FG ' %c '
# }

# autojump
[ -f ${HOMEBREW_PREFIX}/etc/profile.d/autojump.sh ] && . ${HOMEBREW_PREFIX}/etc/profile.d/autojump.sh
autoload -U compinit && compinit

# zmv
autoload zmv

# z
[ -f ${HOMEBREW_PREFIX}/etc/profile.d/z.sh ] && . ${HOMEBREW_PREFIX}/etc/profile.d/z.sh

# functions

## set the tab title to current dir
precmd() {
  local title=""

  if [[ "$PWD" == "$HOME" ]]; then
    title="~"
  else
    title="${PWD##*/}"
  fi

  echo -ne "\e]1;$title\a"
}



## create a folder and go in it
function mcd() {
  mkdir -p "$1" && cd "$1";
}

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

# bind
bindkey '^R' history-incremental-search-backward
bindkey -r '^K'
bindkey '^K^U' _mtxr-to-upper # Ctrl+K + Ctrl+U
bindkey '^K^L' _mtxr-to-lower # Ctrl+K + Ctrl+L

# global variable
# export FIREFOXNIGHTLY_BIN="/Applications/FirefoxNightly.app/Contents/MacOS/firefox"
# export BROWSER=$FIREFOXNIGHTLY_BIN # bug with python
export GIT_EDITOR="nvim"
export VISUAL="code"
export EDITOR="nvim"

# aliases
. ~/.aliases

# node
export NODE_PATH=${HOMEBREW_PREFIX}/lib/node_modules

###-begin-npm-completion-###
#
# npm command completion script
#
# Installation: npm completion >> ~/.bashrc  (or ~/.zshrc)
# Or, maybe: npm completion > ${HOMEBREW_PREFIX}/etc/bash_completion.d/npm
#
if type complete &>/dev/null; then
  _npm_completion () {
    local words cword
    if type _get_comp_words_by_ref &>/dev/null; then
      _get_comp_words_by_ref -n = -n @ -n : -w words -i cword
    else
      cword="$COMP_CWORD"
      words=("${COMP_WORDS[@]}")
    fi

    local si="$IFS"
    IFS=$'\n' COMPREPLY=($(COMP_CWORD="$cword" \
                           COMP_LINE="$COMP_LINE" \
                           COMP_POINT="$COMP_POINT" \
                           npm completion -- "${words[@]}" \
                           2>/dev/null)) || return $?
    IFS="$si"
    if type __ltrim_colon_completions &>/dev/null; then
      __ltrim_colon_completions "${words[cword]}"
    fi
  }
  complete -o default -F _npm_completion npm
elif type compdef &>/dev/null; then
  _npm_completion() {
    local si=$IFS
    compadd -- $(COMP_CWORD=$((CURRENT-1)) \
                 COMP_LINE=$BUFFER \
                 COMP_POINT=0 \
                 npm completion -- "${words[@]}" \
                 2>/dev/null)
    IFS=$si
  }
  compdef _npm_completion npm
elif type compctl &>/dev/null; then
  _npm_completion () {
    local cword line point words si
    read -Ac words
    read -cn cword
    let cword-=1
    read -l line
    read -ln point
    si="$IFS"
    IFS=$'\n' reply=($(COMP_CWORD="$cword" \
                       COMP_LINE="$line" \
                       COMP_POINT="$point" \
                       npm completion -- "${words[@]}" \
                       2>/dev/null)) || return $?
    IFS="$si"
  }
  compctl -K _npm_completion npm
fi
###-end-npm-completion-###

# android
# export ANDROID_HOME=${HOMEBREW_PREFIX}/opt/android-sdk
export ANDROID_HOME=$HOME/Library/Android/sdk

# java
# export JAVA_HOME=$(/usr/libexec/java_home -v15)
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home"
# export JAVA_11_HOME=$(/usr/libexec/java_home -v11)
# export JAVA_14_HOME=$(/usr/libexec/java_home -v14)
# export JAVA_15_HOME=$(/usr/libexec/java_home -v15)

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

# PATH - must be in the end
export PATH=/usr/local/sbin:$PATH # brew
export PATH=${HOMEBREW_PREFIX}/Cellar/:$PATH # brew
export PATH=${HOMEBREW_PREFIX}/lib/node_modules:$PATH # npm
export PATH=${HOMEBREW_PREFIX}/opt/ruby/bin:$PATH # ruby
export PATH=${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin:$PATH # gnu-sed
export PATH=$PATH:$ANDROID_HOME/emulator # android emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools # android platform-tools

export PATH=$MY/git/bin:$PATH # git commands
export PATH=$MY/bin/_:$PATH # own commands

export PATH=$PATH:$MY/bin/shims # add commands to open applications

# local
. ~/.zshrc_local

# add or override commands by via profiled ones
export PATH=$MY/profiles/$OS_PROFILE/bin/_:$PATH

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

eval "$(fnm env --use-on-cd)" > /dev/null 2>&1
eval "$(frum init)"
