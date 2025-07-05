################################################################################
#                                                                              #
#   ⚡ PREZTO INITIALIZATION                                                   #
#   ------------------------                                                   #
#   Loads Prezto framework if available.                                       #
#   https://github.com/sorin-ionescu/prezto                                    #
#                                                                              #
################################################################################

if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi
