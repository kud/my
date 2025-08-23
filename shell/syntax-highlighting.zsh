################################################################################
#                                                                              #
#   🎨 ZSH SYNTAX HIGHLIGHTING CONFIGURATION                                  #
#   ------------------------------------------                                 #
#   Configures zsh-syntax-highlighting plugin styling and patterns.            #
#   https://github.com/zsh-users/zsh-syntax-highlighting                       #
#                                                                              #
################################################################################

if [[ -n "${ZSH_HIGHLIGHT_VERSION:-}" ]]; then
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern line root)
  ZSH_HIGHLIGHT_STYLES[path]='fg=white'
  ZSH_HIGHLIGHT_PATTERNS=('rm*-rf*' 'fg=white,bold,bg=red')
fi
