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

# antidote
source $(brew --prefix)/share/antidote/antidote.zsh

if [[ ! -f ~/.zsh_plugins.zsh ]]; then
  antidote bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.zsh
fi

source ~/.zsh_plugins.zsh


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

## yazi
function yy() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
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
[[ -f $HOME/.config/zsh/aliases.zsh ]] && source $HOME/.config/zsh/aliases.zsh

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

#compdef frum

autoload -U is-at-least

_frum() {
    typeset -A opt_args
    typeset -a _arguments_options
    local ret=1

    if is-at-least 5.2; then
        _arguments_options=(-s -S -C)
    else
        _arguments_options=(-s -C)
    fi

    local context curcontext="$curcontext" state line
    _arguments "${_arguments_options[@]}" \
'--log-level=[The log level of frum commands \[default: info\] \[possible values: quiet, info, error\]]' \
'--ruby-build-mirror=[\[default: https://cache.ruby-lang.org/pub/ruby\]]' \
'--frum-dir=[The root directory of frum installations \[default: $HOME/.frum\]]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
":: :_frum_commands" \
"*::: :->frum" \
&& ret=0
    case $state in
    (frum)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:frum-command-$line[1]:"
        case $line[1] in
            (init)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(install)
_arguments "${_arguments_options[@]}" \
'-l[Lists Ruby versions available to install]' \
'--list[Lists Ruby versions available to install]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
'::version:_values 'version' $(frum install -l)' \
&& ret=0
;;
(uninstall)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':version:_values 'version' $(frum completions --list)' \
&& ret=0
;;
(versions)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(local)
if [ "$(frum completions --list)" != '' ]; then
    local_args='::version:_values 'version' $(frum completions --list)'
else
    local_args='--version[Prints version information]'
fi
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
"${local_args}" \
&& ret=0
;;
(global)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
':version:_values 'version' $(frum completions --list)' \
&& ret=0
;;
(completions)
_arguments "${_arguments_options[@]}" \
'-s+[The shell syntax to use]' \
'--shell=[The shell syntax to use]' \
'-l[Lists installed Ruby versions]' \
'--list[Lists installed Ruby versions]' \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" \
'-h[Prints help information]' \
'--help[Prints help information]' \
'-V[Prints version information]' \
'--version[Prints version information]' \
&& ret=0
;;
        esac
    ;;
esac
}

(( $+functions[_frum_commands] )) ||
_frum_commands() {
    local commands; commands=(
        "init:Sets environment variables for initializing frum" \
"install:Installs a specific Ruby version" \
"uninstall:Uninstall a specific Ruby version" \
"versions:Lists installed Ruby versions" \
"local:Sets the current Ruby version" \
"global:Sets the global Ruby version" \
"completions:Print shell completions to stdout" \
"help:Prints this message or the help of the given subcommand(s)" \
    )
    _describe -t commands 'frum commands' commands "$@"
}
(( $+functions[_frum__completions_commands] )) ||
_frum__completions_commands() {
    local commands; commands=(

    )
    _describe -t commands 'frum completions commands' commands "$@"
}
(( $+functions[_frum__global_commands] )) ||
_frum__global_commands() {
    local commands; commands=(

    )
    _describe -t commands 'frum global commands' commands "$@"
}
(( $+functions[_frum__help_commands] )) ||
_frum__help_commands() {
    local commands; commands=(

    )
    _describe -t commands 'frum help commands' commands "$@"
}
(( $+functions[_frum__init_commands] )) ||
_frum__init_commands() {
    local commands; commands=(

    )
    _describe -t commands 'frum init commands' commands "$@"
}
(( $+functions[_frum__install_commands] )) ||
_frum__install_commands() {
    local commands; commands=(

    )
    _describe -t commands 'frum install commands' commands "$@"
}
(( $+functions[_frum__local_commands] )) ||
_frum__local_commands() {
    local commands; commands=(

    )
    _describe -t commands 'frum local commands' commands "$@"
}
(( $+functions[_frum__uninstall_commands] )) ||
_frum__uninstall_commands() {
    local commands; commands=(

    )
    _describe -t commands 'frum uninstall commands' commands "$@"
}
(( $+functions[_frum__versions_commands] )) ||
_frum__versions_commands() {
    local commands; commands=(

    )
    _describe -t commands 'frum versions commands' commands "$@"
}

# android
# export ANDROID_HOME=${HOMEBREW_PREFIX}/opt/android-sdk
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME

# java
# export JAVA_HOME="/usr/local/opt/sdkman-cli/libexec/candidates/java/current/bin/java"
# export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home"
# export JAVA_HOME=$(/usr/libexec/java_home -v15)
# export JAVA_11_HOME=$(/usr/libexec/java_home -v11)
# export JAVA_14_HOME=$(/usr/libexec/java_home -v14)
# export JAVA_15_HOME=$(/usr/libexec/java_home -v15)

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
