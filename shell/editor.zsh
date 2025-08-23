################################################################################
#                                                                              #
#   ⌨️  EDITOR CONFIGURATION                                                   #
#   ----------------------                                                     #
#   Vi mode key bindings and editor settings for enhanced terminal experience. #
#                                                                              #
################################################################################

# Vi key bindings
bindkey -v

# Editor options
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# Vi mode fixes
bindkey -M vicmd 'x' delete-char
bindkey -M viins '^?' backward-delete-char

# Arrow keys in vi insert mode
bindkey -M viins '^[[A' up-line-or-history
bindkey -M viins '^[[B' down-line-or-history
bindkey -M viins '^[[C' forward-char
bindkey -M viins '^[[D' backward-char

# Home/End keys
bindkey -M viins '^[[H' beginning-of-line
bindkey -M viins '^[[F' end-of-line
bindkey -M vicmd '^[[H' beginning-of-line
bindkey -M vicmd '^[[F' end-of-line
