################################################################################
#                                                                              #
#   📚 ZSH HISTORY CONFIGURATION                                               #
#   -------------------------                                                  #
#   Optimized history settings for better command recall and management.       #
#                                                                              #
################################################################################

# -----------------------------
# History Size & Storage
# -----------------------------
HISTSIZE=10000                # Number of commands to keep in memory
SAVEHIST=10000                # Number of commands to save to file
HISTFILE=~/.zsh_history       # History file location

# -----------------------------
# Basic History Options
# -----------------------------
setopt append_history          # Append to history file rather than replacing
setopt hist_ignore_dups        # Don't record duplicate consecutive commands
setopt share_history           # Share history between all sessions

# -----------------------------
# Advanced History Options
# -----------------------------
setopt extended_history        # Record timestamp of command in HISTFILE
setopt hist_expire_dups_first  # Delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_all_dups    # Delete old recorded entry if new entry is a duplicate
setopt hist_find_no_dups       # Do not display a line previously found
setopt hist_ignore_space       # Ignore commands that start with space
setopt hist_save_no_dups       # Don't write duplicate entries in the history file
setopt hist_reduce_blanks      # Remove extra whitespace from history entries
setopt hist_verify             # Show command with history expansion to user before running it
setopt hist_no_store           # Don't store history and fc commands in history
setopt inc_append_history      # Write to the history file immediately, not when the shell exits
