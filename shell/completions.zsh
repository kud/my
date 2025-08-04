################################################################################
#                                                                              #
#   � ZSH COMPLETIONS CONFIGURATION                                           #
#   ---------------------------------                                          #
#   Central completion system setup and custom completions.                    #
#                                                                              #
################################################################################

# -----------------------------------------------------------------------------
# ZSH Completion System
# -----------------------------------------------------------------------------
# Only rebuild completions if needed, otherwise use cached (from Scott Spence's guide)
autoload -Uz compinit

# Enhanced completion initialization with caching
_comp_path="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
# #q expands globs in conditional expressions
if [[ $_comp_path(#qNmh-20) ]]; then
  # -C (skip function check) implies -i (skip security check)
  compinit -C -d "$_comp_path"
else
  mkdir -p "$_comp_path:h"
  compinit -i -d "$_comp_path"
  # Keep $_comp_path younger than cache time even if it isn't regenerated
  touch "$_comp_path"
fi
unset _comp_path

# -----------------------------------------------------------------------------
# Completion Options
# -----------------------------------------------------------------------------

setopt COMPLETE_IN_WORD     # Complete from both ends of a word
setopt ALWAYS_TO_END        # Move cursor to end of completed word
setopt PATH_DIRS            # Perform path search on command names with slashes
setopt AUTO_MENU            # Show completion menu on successive tab press
setopt AUTO_LIST            # Automatically list choices on ambiguous completion
setopt AUTO_PARAM_SLASH     # Add trailing slash if completed parameter is directory
setopt EXTENDED_GLOB        # Needed for file modification glob modifiers with compinit
unsetopt MENU_COMPLETE      # Don't autoselect first completion entry
unsetopt FLOW_CONTROL       # Disable start/stop characters in shell editor

# Add homebrew completions to $fpath if available
if (( $+commands[brew] )); then
  brew_prefix=${HOMEBREW_PREFIX:-${HOMEBREW_REPOSITORY:-$commands[brew]:A:h:h}}
  [[ $brew_prefix == '/usr/local/Homebrew' ]] && brew_prefix=$brew_prefix:h
  fpath=($brew_prefix/share/zsh/site-functions(/N) $fpath)
  unset brew_prefix
fi

# -----------------------------------------------------------------------------
# Completion Styles
# -----------------------------------------------------------------------------

# Use caching for commands like dpkg and apt
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'm:{[:upper:]}={[:lower:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
unsetopt CASE_GLOB

# Group matches and describe
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' -- %d --'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*' format ' -- %d --'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Use LS_COLORS for completion
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Fuzzy match mistyped completions
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'

# Directory completion
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*' squeeze-slashes true

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
  adm amanda apache avahi beaglidx bin cacti canna clamav daemon \
  dbus distcache dovecot fax ftp games gdm gkrellmd gopher \
  hacluster haldaemon halt hsqldb ident junkbust ldap lp mail \
  mailman mailnull mldonkey mysql nagios \
  named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
  operator pcap postfix postgres privoxy pulse pvm quagga radvd \
  rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs '_*'

# SSH/SCP/RSYNC completion
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'

################################################################################
#                                                                              #
#    FRUM COMPLETION                                                         #
#   --------------------                                                       #
#   Provides completion for the `frum` Ruby version manager.                   #
#                                                                              #
################################################################################
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
'--log-level=[The log level of frum commands [default: info] [possible values: quiet, info, error]]' \
'--ruby-build-mirror=[default: https://cache.ruby-lang.org/pub/ruby]' \
'--frum-dir=[The root directory of frum installations [default: $HOME/.frum]]' \
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
