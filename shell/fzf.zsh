# ==============================================================================
# FZF & FZF-TAB CONFIGURATION
# ------------------------------------------------------------------------------
# Complete initialization, colors, preview, and fzf-tab integration.
# ==============================================================================

# FZF UI configuration
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --inline-info --border --color=fg:#c9d1d9,bg:-1,hl:#79c0ff,border:#181a1d --color=fg+:#c9d1d9,bg+:-1,hl+:#79c0ff,border:#181a1d --color=info:#b3b3b3,prompt:#58a6ff,pointer:#f778ba --color=marker:#f778ba,spinner:#b3b3b3,header:-1"

# FZF-TAB recommended configuration
zstyle ':fzf-tab:*' ansi-colors true
zstyle ':fzf-tab:*' fzf-flags '--height=40%' '--layout=reverse' '--info=inline' '--color=fg+:italic'
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always $realpath'

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

# FZF previews
export FZF_CTRL_T_OPTS="--preview '([[ -f {} ]] && (bat --style=numbers --color=always {} 2>/dev/null || cat {})) || ([[ -d {} ]] && (tree -C {} | head -200))' --preview-window=right:50%:wrap"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200' --preview-window=right:50%"

# Load fzf
source <(fzf --zsh)
