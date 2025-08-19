# ################################################################################
#                                                                                #
#   🚦 RESOURCE LIMITS                                                           #
#   -------------------                                                          #
#   System resource limits for development tools like Watchman, Metro, and      #
#   React Native. Works in conjunction with system-wide LaunchDaemon limits.    #
#                                                                                #
# ################################################################################

# Set file descriptor limit for this shell session
# This works with the system-wide limits set by core/system/limits.zsh
target=65536
hard=$(ulimit -Hn)
# Validate that $hard is numeric before comparison
if [ "$hard" != "unlimited" ] && [[ "$hard" =~ ^[0-9]+$ ]]; then
  [ "$target" -gt "$hard" ] && target="$hard"
fi
ulimit -n "$target"
