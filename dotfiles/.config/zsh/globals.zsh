# ################################################################################
#                                                                                #
#   🌍 GLOBAL VARIABLES                                                          #
#   ---------------                                                              #
#   User and environment global variables.                                       #
#                                                                                #
# ################################################################################

export MY=$HOME/my
export TMP=$HOME/__tmp
export SYNC_FOLDER=$HOME/pCloud

export GIT_EDITOR="nvim"
export VISUAL="code"
export EDITOR="nvim"

# -----------------------------
# Zsh History Optimisation
# -----------------------------
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt append_history
setopt hist_ignore_dups
setopt share_history
