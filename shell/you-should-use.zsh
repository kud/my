# ################################################################################
#                                                                                #
#   💡 ZSH-YOU-SHOULD-USE CONFIGURATION                                          #
#   ------------------------------------                                         #
#   Configuration for alias reminder plugin.                                     #
#                                                                                #
# ################################################################################

# Show reminder after command execution (cleaner output)
export YSU_MESSAGE_POSITION="after"

# Customize the reminder message format - clean and readable
# The message uses tput for bold formatting and a leading newline for clarity.
# Icon can be customized by setting YSU_ICON before sourcing; defaults to an info glyph
: "${YSU_ICON:=ⓘ}"
export YSU_MESSAGE_FORMAT="$(echo; echo "$(tput setaf 3)${YSU_ICON}$(tput sgr0)  Instead of $(tput bold)%command$(tput sgr0), you can use $(tput bold)%alias$(tput sgr0)")"

# Ignore certain commands that might not need aliases
export YSU_IGNORED_ALIASES=("g" "l" "ll" "la")

# Set minimum command length to trigger reminders (avoid very short commands)
export YSU_MINIMUM_COMMAND_LENGTH=3
