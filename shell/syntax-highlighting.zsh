################################################################################
#                                                                              #
#   🎨 ZSH SYNTAX HIGHLIGHTING CONFIGURATION                                  #
#   ------------------------------------------                                 #
#   Configures zsh-syntax-highlighting plugin styling and patterns.            #
#   https://github.com/zsh-users/zsh-syntax-highlighting                       #
#                                                                              #
################################################################################

# Only configure if zsh-syntax-highlighting is loaded
if [[ -n "${ZSH_HIGHLIGHT_VERSION:-}" ]]; then
  
  # Set syntax highlighters
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern line root)
  
  # Set syntax highlighting styles
  ZSH_HIGHLIGHT_STYLES[path]='fg=white'
  
  # Set syntax pattern styles  
  ZSH_HIGHLIGHT_PATTERNS=('rm*-rf*' 'fg=white,bold,bg=red')
  
fi