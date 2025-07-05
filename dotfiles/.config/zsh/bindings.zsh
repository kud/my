############################################################
# ⌨️  Key Bindings
############################################################

# Search backward in history with Ctrl+R
bindkey '^R' history-incremental-search-backward

# Unbind Ctrl+K
bindkey -r '^K'

# Custom: Ctrl+K + Ctrl+U to upper, Ctrl+K + Ctrl+L to lower
bindkey '^K^U' _mtxr-to-upper # Ctrl+K + Ctrl+U
bindkey '^K^L' _mtxr-to-lower # Ctrl+K + Ctrl+L
