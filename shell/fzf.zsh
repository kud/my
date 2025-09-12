################################################################################
#                                                                              #
#   🔍 FZF & FZF-TAB CONFIGURATION - TOKYO NIGHT EDITION                      #
#   -------------------------------------------------------                    #
#   Complete initialization, colors, preview, and fzf-tab integration.        #
#   Features Tokyo Night color scheme and enhanced history search.            #
#                                                                              #
#   Key Features:                                                              #
#   • Tokyo Night color scheme for consistent theming                         #
#   • Enhanced Ctrl+R history search with preview                             #
#   • Better preview options with fallbacks                                   #
#   • Rounded borders and modern styling                                      #
#                                                                              #
################################################################################

# FZF UI configuration - Tokyo Night theme
export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --inline-info --border=rounded --ansi --tabstop=2 --color=bg+:#283457,bg:#1a1b26,spinner:#bb9af7,hl:#7aa2f7 --color=fg:#c0caf5,header:#7aa2f7,info:#7dcfff,pointer:#bb9af7 --color=marker:#9ece6a,fg+:#c0caf5,prompt:#7aa2f7,hl+:#7aa2f7 --color=border:#565f89"

# FZF-TAB recommended configuration - Tokyo Night styled
zstyle ':fzf-tab:*' ansi-colors true
zstyle ':fzf-tab:*' fzf-flags '--height=50%' '--layout=reverse' '--info=inline' '--border=rounded' '--color=bg+:#283457,bg:#1a1b26,hl:#7aa2f7,fg:#c0caf5,header:#7aa2f7,info:#7dcfff,pointer:#bb9af7,marker:#9ece6a,fg+:#c0caf5,prompt:#7aa2f7,hl+:#7aa2f7,border:#565f89'
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'

# FZF default commands
if command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git 2>/dev/null || find . -type d -not -path "*/.git/*" 2>/dev/null'
elif command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
else
  export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/.git/*" 2>/dev/null'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='find . -type d -not -path "*/.git/*" 2>/dev/null'
fi

# FZF previews - Enhanced with better preview options
export FZF_CTRL_T_OPTS="--preview '([[ -f {} ]] && (bat --style=numbers --color=always --theme=TwoDark {} 2>/dev/null || cat {})) || ([[ -d {} ]] && (eza --tree --color=always --icons {} 2>/dev/null || tree -C {} 2>/dev/null | head -200 || ls -la --color=always {}))' --preview-window=right:50%:wrap:border-rounded --bind='ctrl-/:toggle-preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons {} 2>/dev/null || tree -C {} 2>/dev/null | head -200 || ls -la --color=always {}' --preview-window=right:50%:border-rounded --bind='ctrl-/:toggle-preview'"

# Enhanced history search (Ctrl+R replacement)
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=down:3:hidden:wrap:border-rounded --bind='ctrl-/:toggle-preview' --bind='ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' --color=header:#7aa2f7,info:#7dcfff --header='Press CTRL-Y to copy command into clipboard' --border"

# Load fzf
source <(fzf --zsh)

# Enhanced history search function - Tokyo Night themed
fzf_history_search() {
    local selected=$(
        fc -rl 1 | awk '{$1=""; print substr($0,2)}' |
        fzf --query="$LBUFFER" \
            --height=50% \
            --layout=reverse \
            --info=inline \
            --border=rounded \
            --prompt="History ❯ " \
            --color=bg+:#283457,bg:#1a1b26,hl:#7aa2f7,fg:#c0caf5,header:#7aa2f7,info:#7dcfff,pointer:#bb9af7,marker:#9ece6a,fg+:#c0caf5,prompt:#7aa2f7,hl+:#7aa2f7,border:#565f89 \
            --preview-window=down:3:hidden:wrap:border-rounded \
            --bind='ctrl-/:toggle-preview' \
            --bind='ctrl-y:execute-silent(echo -n {} | pbcopy 2>/dev/null || echo -n {} | xclip -selection clipboard 2>/dev/null)+abort' \
            --header='󰋚 Enhanced History Search | Ctrl-Y: Copy | Ctrl-/: Preview'
    )
    if [[ -n $selected ]]; then
        LBUFFER=$selected
        zle reset-prompt
    fi
}

# Register the widget and bind it to Ctrl+R
zle -N fzf_history_search
bindkey '^R' fzf_history_search
