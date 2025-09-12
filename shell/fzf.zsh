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

FZF_TOKYONIGHT_COLORS="--color=fg:${TN_FZF_FG},bg:-1,hl:${TN_FZF_CYAN},border:${TN_FZF_BG_HIGHLIGHT},scrollbar:#7e9be8 --color=fg+:${TN_FZF_FG},bg+:${TN_FZF_BG_HIGHLIGHT},hl+:${TN_FZF_MAGENTA},prompt:${TN_FZF_BLUE},pointer:${TN_FZF_ORANGE} --color=marker:${TN_FZF_GREEN},spinner:${TN_FZF_MAGENTA},info:${TN_FZF_COMMENT},header:${TN_FZF_ORANGE}"

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

# Ctrl-R history widget (Tokyonight styled) moved from functions.zsh
fzf-history-widget() {
  if ! command -v fzf >/dev/null 2>&1; then
    zle -M "fzf not found"
    return 1
  fi
  # Minimal colors: grey numbers + per-command color + icon
  local icon=${FZF_HISTORY_ICON:-$''}
  local prompt="${icon}  "
  local C_RESET=$'\e[39m'
  local C_NUM=$'\e[38;2;86;95;137m'
  local C_DEFAULT=$'\e[38;2;192;202;245m'
  local C_GIT=$'\e[38;2;187;154;247m'
  local C_PKG=$'\e[38;2;158;206;106m'
  local C_BUILD=$'\e[38;2;255;158;100m'
  local C_NET=$'\e[38;2;125;207;255m'
  local C_SYS=$'\e[38;2;122;162;247m'
  local tmp_newest=$(mktemp -t fzf-hist.XXXXXX)
  builtin fc -rl 1 | awk -v C_NUM="$C_NUM" -v C_RESET="$C_RESET" \
    -v C_DEFAULT="$C_DEFAULT" -v C_GIT="$C_GIT" -v C_PKG="$C_PKG" \
    -v C_BUILD="$C_BUILD" -v C_NET="$C_NET" -v C_SYS="$C_SYS" \
    -v USE_ICONS="${FZF_HISTORY_ENABLE_ICONS:-1}" '
    function colorize(cmd){
      if(cmd=="git") return C_GIT;
      if(cmd=="npm"||cmd=="pnpm"||cmd=="yarn"||cmd=="brew") return C_PKG;
      if(cmd=="make"||cmd=="cmake"||cmd=="cargo"||cmd=="go") return C_BUILD;
      if(cmd=="curl"||cmd=="wget"||cmd=="ssh"||cmd=="scp"||cmd=="kubectl"||cmd=="docker") return C_NET;
      if(cmd=="nvim"||cmd=="vim"||cmd=="code") return C_SYS;
      return C_DEFAULT;
    }
    function icon_for(cmd){
      if(USE_ICONS==0) return "";
      if(cmd=="git") return " ";
      if(cmd=="npm"||cmd=="pnpm"||cmd=="yarn"||cmd=="brew"||cmd=="gem"||cmd=="pip"||cmd=="pip3"||cmd=="cargo") return " ";
      if(cmd=="make"||cmd=="cmake"||cmd=="go") return " ";
      if(cmd=="curl"||cmd=="wget"||cmd=="ssh"||cmd=="scp"||cmd=="kubectl"||cmd=="docker") return " ";
      if(cmd=="nvim"||cmd=="vim") return " ";
      if(cmd=="code") return " ";
      return " ";
    }
    {
      num=$1; $1=""; gsub(/^ +/, "");
      line=$0; split(line,a," "); cmd=a[1]; clr=colorize(cmd); ic=icon_for(cmd);
      printf "%s%5s%s %s%s%s%s", C_NUM, num, C_RESET, clr, ic, cmd, C_RESET;
      for(i=2;i<=length(a);i++){ printf " %s", a[i] }
      printf "\033[0m\n"
    }' >| "$tmp_newest"
  local selected
  # Use existing global FZF_DEFAULT_OPTS (theme) without overriding
  selected=$(cat "$tmp_newest" | fzf --ansi --no-sort --query "$LBUFFER" --prompt "$prompt")
  local st=$?
  rm -f -- "$tmp_newest" || true
  (( st != 0 )) && return
  if [[ -n $selected ]]; then
    selected=$(printf '%s' "$selected" | sed -E 's/\x1B\[[0-9;]*[A-Za-z]//g; s/^[[:space:]]*[0-9]+[[:space:]]+//; s/^[][[:space:]]+//')
    BUFFER=$selected
    CURSOR=$#BUFFER
    zle redisplay
  fi
}
zle -N fzf-history-widget
if [[ -z ${_ORIG_CTRL_R_BINDING:-} ]]; then
  _ORIG_CTRL_R_BINDING=$(bindkey '^R' | awk '{print $2}')
fi
bindkey '^R' fzf-history-widget
