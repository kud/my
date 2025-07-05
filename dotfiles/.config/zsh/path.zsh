################################################################################
#                                                                              #
#   🛣️  PATH SETUP                                                            #
#   -------------                                                             #
#   All custom and system PATH modifications in one place.                     #
#                                                                              #
################################################################################

# Homebrew
export PATH=${HOMEBREW_PREFIX}/sbin:$PATH
export PATH=${HOMEBREW_PREFIX}/Cellar/:$PATH
export PATH=${HOMEBREW_PREFIX}/opt/curl/bin:$PATH
export PATH=${HOMEBREW_PREFIX}/opt/ruby/bin:$PATH
export PATH=${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin:$PATH
export PATH=${HOMEBREW_PREFIX}/lib/node_modules:$PATH

# Android
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Console Ninja
export PATH=$HOME/.console-ninja/.bin:$PATH

# Own commands
export PATH=$MY/bin/_:$PATH

# Application shims
export PATH=$PATH:$MY/bin/shims

# Profiled overrides
export PATH=$MY/profiles/$OS_PROFILE/bin/_:$PATH
