# ################################################################################
#                                                                                #
#   📦 HOMEBREW CASK                                                             #
#   -----------------                                                            #
#   Homebrew Cask options.                                                       #
#                                                                                #
# ################################################################################

# Set Homebrew prefix (with fallback for older Intel Macs)
export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-$(brew --prefix 2>/dev/null || echo /usr/local)}"

export HOMEBREW_CASK_OPTS=--appdir=/Applications
