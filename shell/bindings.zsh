# ################################################################################
#                                                                                #
#   ⌨️  KEY BINDINGS                                                             #
#   ------------                                                                #
#   Custom Zsh key bindings for improved usability.                             #
#                                                                                #
# ################################################################################

function _mtxr-to-upper {
  LBUFFER=${LBUFFER:u}
}
zle -N _mtxr-to-upper

function _mtxr-to-lower {
  LBUFFER=${LBUFFER:l}
}
zle -N _mtxr-to-lower

# -----------------------------
# Key Bindings
# -----------------------------
#  By default in Zsh, Ctrl+K kills (deletes) text from the cursor to the end of the line. This command removes that binding, so pressing Ctrl+K won't do anything.
# Common reasons to unbind Ctrl+K:
# - Preventing accidental text deletion
# - Freeing it up for a custom binding
# - Avoiding conflicts with other tools/plugins
bindkey -r '^K'

bindkey '^R' history-incremental-search-backward
bindkey '^K^U' _mtxr-to-upper
bindkey '^K^L' _mtxr-to-lower
