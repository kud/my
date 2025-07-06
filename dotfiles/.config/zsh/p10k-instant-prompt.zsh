# ################################################################################
#                                                                                #
#   ⚡ POWERLEVEL10K INSTANT PROMPT INITIALISATION                               #
#   ------------------------------------------                                   #
#   Must be sourced at the very top of .zshrc for best performance.             #
#                                                                                #
# ################################################################################
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
