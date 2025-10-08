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
autoload -Uz compinit

_comp_path="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
if [[ $_comp_path(#qNmh-20) ]]; then
  compinit -C -d "$_comp_path"
else
  mkdir -p "$_comp_path:h"
  compinit -i -d "$_comp_path"
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
zstyle ':completion:*:corrections' format ' %F{green}%d (errors: %e)%f |'
zstyle ':completion:*:descriptions' format ' %d |'
zstyle ':completion:*:messages' format ' %F{purple}%d%f |'
zstyle ':completion:*:warnings' format ' %F{red}no matches found%f |'
zstyle ':completion:*' format ' %d |'
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

# mise completion
if command -v mise >/dev/null 2>&1; then
  eval "$(mise completion zsh)"
fi
