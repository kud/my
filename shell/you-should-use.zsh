# ################################################################################
#                                                                                #
#   💡 ZSH-YOU-SHOULD-USE CONFIGURATION                                          #
#   ------------------------------------                                         #
#   Configuration for alias reminder plugin.                                     #
#                                                                                #
# ################################################################################

# Show reminder after command execution (cleaner output)
export YSU_MESSAGE_POSITION="after"

# Customize the reminder message format
export YSU_MESSAGE_FORMAT="$(tput setaf 3)💡 Found existing alias: $(tput bold)%alias$(tput sgr0)$(tput setaf 3) for $(tput bold)%command$(tput sgr0)"

# Ignore certain commands that might not need aliases
export YSU_IGNORED_ALIASES=("g" "l" "ll" "la")

# Set minimum command length to trigger reminders (avoid very short commands)
export YSU_MINIMUM_COMMAND_LENGTH=3
