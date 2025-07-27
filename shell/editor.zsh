################################################################################
#                                                                              #
#   ⌨️  EDITOR CONFIGURATION                                                   #
#   ----------------------                                                     #
#   Replaces prezto editor module functionality.                              #
#   Sets vi key bindings and editor options.                                  #
#                                                                              #
################################################################################

# -----------------------------
# Key Bindings Mode
# -----------------------------
# Set vi key bindings (like prezto editor module)
bindkey -v

# -----------------------------
# Editor Options
# -----------------------------
# Beep on error in line editor (like prezto)
setopt BEEP

# -----------------------------
# Word Characters
# -----------------------------
# Define what characters are considered part of a word
# (matches prezto default)
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# -----------------------------
# Dot Expansion Function
# -----------------------------
# Auto-expand .... to ../.. (like prezto dot-expansion)
function expand-dot-to-parent-directory-path {
  if [[ $LBUFFER = *.. ]]; then
    LBUFFER+='/..'
  else
    LBUFFER+='.'
  fi
}
zle -N expand-dot-to-parent-directory-path

# Enable dot expansion
bindkey "." expand-dot-to-parent-directory-path

# -----------------------------
# Essential Vi Mode Fixes
# -----------------------------
# Fix Delete key in vi command mode
bindkey -M vicmd 'x' delete-char

# Fix backspace in vi insert mode
bindkey -M viins '^?' backward-delete-char

# Fix arrow keys in vi insert mode
bindkey -M viins '^[[A' up-line-or-history
bindkey -M viins '^[[B' down-line-or-history
bindkey -M viins '^[[C' forward-char
bindkey -M viins '^[[D' backward-char

# Fix Home/End keys
bindkey -M viins '^[[H' beginning-of-line
bindkey -M viins '^[[F' end-of-line
bindkey -M vicmd '^[[H' beginning-of-line
bindkey -M vicmd '^[[F' end-of-line
