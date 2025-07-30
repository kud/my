# ──────────────────────────────────────────────
# History Substring Search Configuration
# History substring search configuration
# ──────────────────────────────────────────────

# Direct configuration for history substring search plugin
# configuration of the zsh-history-substring-search plugin

# ────────────── Search Colors ──────────────

# Highlight color for found matches
# Default: bg=magenta,fg=white,bold
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=magenta,fg=white,bold'

# Highlight color for not-found matches
# Default: bg=red,fg=white,bold
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'

# ────────────── Search Options ──────────────

# Globbing flags (i = case insensitive)
export HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS='i'

# Enable fuzzy searching (uncomment to enable)
# export HISTORY_SUBSTRING_SEARCH_FUZZY=1

# Ensure unique results (uncomment to enable)
# export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

# Only search from beginning of command (uncomment to enable)
# export HISTORY_SUBSTRING_SEARCH_PREFIXED=1

# ────────────── Key Bindings ──────────────

# Wait for plugin to load before setting up keybindings
if (( $+functions[history-substring-search-up] )); then
    _setup_history_substring_search_keys() {
        # Emacs mode bindings
        bindkey -M emacs '^P' history-substring-search-up
        bindkey -M emacs '^N' history-substring-search-down

        # Vi command mode bindings
        bindkey -M vicmd 'k' history-substring-search-up
        bindkey -M vicmd 'j' history-substring-search-down

        # Both emacs and vi insert mode - arrow keys
        bindkey '^[[A' history-substring-search-up      # Up arrow
        bindkey '^[[B' history-substring-search-down    # Down arrow

        # Alternative arrow key sequences (for different terminals)
        bindkey '\eOA' history-substring-search-up      # Up arrow
        bindkey '\eOB' history-substring-search-down    # Down arrow
    }

    _setup_history_substring_search_keys
    unfunction _setup_history_substring_search_keys
fi

# ────────────── Usage Notes ──────────────
#
# How to use:
# 1. Type the beginning of a command
# 2. Press UP arrow to search backwards through history
# 3. Press DOWN arrow to search forwards through history
# 4. Only commands that start with your typed text will be shown
#
# Example:
# - Type: git
# - Press UP: cycles through "git commit", "git push", etc.
# - Type: git co
# - Press UP: cycles through "git commit", "git checkout", etc.
