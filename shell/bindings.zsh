# ################################################################################
#                                                                                #
#   ⌨️  KEY BINDINGS                                                             #
#   ------------                                                                #
#   Custom Zsh key bindings for improved usability.                             #
#                                                                                #
# ################################################################################

# Text transformation functions
function _mtxr-to-upper {
  LBUFFER=${LBUFFER:u}
}
zle -N _mtxr-to-upper

function _mtxr-to-lower {
  LBUFFER=${LBUFFER:l}
}
zle -N _mtxr-to-lower

# Dot expansion function - auto-expand .... to ../..
function expand-dot-to-parent-directory-path {
  if [[ $LBUFFER = *.. ]]; then
    LBUFFER+='/..'
  else
    LBUFFER+='.'
  fi
}
zle -N expand-dot-to-parent-directory-path

# General key bindings
bindkey -r '^K' # Remove Ctrl+K binding (normally kills text to end of line) to prevent accidental deletion
bindkey '^R' history-incremental-search-backward
bindkey '^K^U' _mtxr-to-upper
bindkey '^K^L' _mtxr-to-lower
bindkey "." expand-dot-to-parent-directory-path
