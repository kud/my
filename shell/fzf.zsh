################################################################################
#                                                                              #
#   🔍 FZF & FZF-TAB CONFIGURATION                                             #
#   -------------------------------                                            #
#   Complete initialization, colors, preview, and fzf-tab integration.        #
#                                                                              #
################################################################################

# FZF UI configuration
# Tokyonight (storm) palette mapped for FZF (keeps transparent bg via bg:-1)
TN_FZF_FG="#c0caf5"
TN_FZF_BG="#24283b"
TN_FZF_BG_DARK="#1f2335"
TN_FZF_BG_HIGHLIGHT="#292e42"
TN_FZF_BLUE="#7aa2f7"
TN_FZF_CYAN="#7dcfff"
TN_FZF_MAGENTA="#bb9af7"
TN_FZF_ORANGE="#ff9e64"
TN_FZF_GREEN="#9ece6a"
TN_FZF_COMMENT="#565f89"

FZF_TOKYONIGHT_COLORS="--color=fg:${TN_FZF_FG},bg:-1,hl:${TN_FZF_CYAN},border:${TN_FZF_BG_HIGHLIGHT} --color=fg+:${TN_FZF_FG},bg+:${TN_FZF_BG_HIGHLIGHT},hl+:${TN_FZF_MAGENTA},prompt:${TN_FZF_BLUE},pointer:${TN_FZF_ORANGE} --color=marker:${TN_FZF_GREEN},spinner:${TN_FZF_MAGENTA},info:${TN_FZF_COMMENT},header:${TN_FZF_ORANGE}"

export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --inline-info --border $FZF_TOKYONIGHT_COLORS"

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
