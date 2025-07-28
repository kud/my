# ################################################################################
#                                                                                #
#   🔍 FZF INITIALISATION                                                        #
#   ---------------------                                                        #
#   Loads fzf key bindings and completion with enhanced configuration.           #
#                                                                                #
# ################################################################################

# Enhanced FZF configuration
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"

# Use ripgrep for even faster search if available, otherwise fallback to fd, then find
if command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git 2>/dev/null || find . -type d -not -path "*/\.git/*" 2>/dev/null'
elif command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
else
  export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*" 2>/dev/null'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='find . -type d -not -path "*/\.git/*" 2>/dev/null'
fi

# Enhanced file preview with syntax highlighting
export FZF_CTRL_T_OPTS="--preview '([[ -f {} ]] && (bat --style=numbers --color=always {} 2>/dev/null || cat {})) || ([[ -d {} ]] && (tree -C {} | head -200))' --preview-window=right:50%:wrap"

# Enhanced directory preview
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200' --preview-window=right:50%"

# Load fzf
source <(fzf --zsh)
