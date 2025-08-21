# ################################################################################
#                                                                                #
#   🟢 NODE.JS ENVIRONMENT INITIALISATION                                        #
#   -------------------------------                                              #
#   Sets up Node.js via fnm and configures npm global packages.                  #
#                                                                                #
# ################################################################################

# npm global PATH is now managed in path.zsh for centralized PATH management

# Initialize fnm (Fast Node Manager)
eval "$(fnm env --use-on-cd --shell zsh)"

# Set NODE_PATH to the active Node.js version's modules
# export NODE_PATH=${HOMEBREW_PREFIX}/lib/node_modules
