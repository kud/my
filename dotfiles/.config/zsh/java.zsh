################################################################################
#                                                                              #
#   ☕ JAVA ENVIRONMENT INITIALIZATION                                          #
#   -------------------------------                                            #
#   Sets up SDKMAN and related Java environment variables.                     #
#                                                                              #
################################################################################

export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
