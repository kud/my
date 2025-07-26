# ################################################################################
#                                                                                #
#   ⌨️  KEY BINDINGS                                                             #
#   ------------                                                                #
#   Custom Zsh key bindings for improved usability.                             #
#                                                                                #
# ################################################################################

# Search backward in history with Ctrl+R
bindkey '^R' history-incremental-search-backward

# Unbind Ctrl+K
bindkey -r '^K'

# Custom: Ctrl+K + Ctrl+U to upper-case, Ctrl+K + Ctrl+L to lower-case
bindkey '^K^U' _mtxr-to-upper # Ctrl+K + Ctrl+U (upper-case)
bindkey '^K^L' _mtxr-to-lower # Ctrl+K + Ctrl+L (lower-case)
