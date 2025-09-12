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

# Core defaults: smart case, border, improved layout, cycle, marker & multi-select hints
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --info=inline --border rounded --margin=0,2 --padding=0,1 \
  --prompt '❯ ' --pointer='█' --marker='█' --separator='─' --scrollbar='┃' \
  --cycle --tabstop=4 --highlight-line --color=hl:#7dcfff,hl+:#bb9af7 --ansi \
  --bind 'tab:down,btab:up' --bind 'ctrl-a:select-all,ctrl-d:deselect-all' \
  --bind 'ctrl-f:page-down,ctrl-b:page-up,ctrl-u:half-page-up,ctrl-d:half-page-down' \
  --bind 'alt-j:down,alt-k:up,alt-p:toggle-preview' \
  --bind 'ctrl-y:execute-silent(echo {+} | pbcopy)+abort' \
  --bind 'ctrl-e:execute(echo {+} | xargs -I{} $EDITOR {} < /dev/tty)' \
  --bind 'ctrl-space:toggle+down' $FZF_TOKYONIGHT_COLORS"

# FZF-TAB recommended configuration
zstyle ':fzf-tab:*' ansi-colors true
zstyle ':fzf-tab:*' fzf-flags '--height=50%' '--layout=reverse' '--info=inline' '--border=rounded' '--prompt= ' '--marker=✓' '--ansi' '--preview-window=right:55%:wrap'
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# Enrich different completion contexts with previews
zstyle ':fzf-tab:complete:*:options' fzf-preview 'echo -- $word; whatis $word 2>/dev/null | head -5'
zstyle ':fzf-tab:complete:*:*:processes' fzf-preview 'ps -o pid,ppid,command -p ${word%% *} 2>/dev/null'
zstyle ':fzf-tab:complete:*:*:exec' fzf-preview 'command -v $word || echo not found'
zstyle ':fzf-tab:complete:*:*:parameter-*' fzf-preview 'print -r -- ${(P)word} 2>/dev/null | head -200'
zstyle ':fzf-tab:complete:*:*:aliases' fzf-preview 'alias $word'
zstyle ':fzf-tab:complete:*:*:functions' fzf-preview 'type $word | head -200'
# Git status preview when completing paths inside a repo
zstyle ':fzf-tab:complete:(\*|)git-(add|restore|checkout|diff|reset):*' fzf-preview 'git -c color.ui=always diff --cached -- $realpath 2>/dev/null || git -c color.ui=always diff -- $realpath 2>/dev/null || ls -ld -- $realpath'
# Directory completion: rich preview using lsd/exa/ls fallback
zstyle ':fzf-tab:complete:cd:*' fzf-preview '([[ -d $realpath ]] && { if command -v lsd >/dev/null 2>&1; then lsd -1 --color=always $realpath; elif command -v exa >/dev/null 2>&1; then exa -1 --color=always $realpath; else ls -1 $realpath; fi; }) 2>/dev/null'

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
# File (ctrl-t) preview: prefer bat -> cat; directory: tree/lsd/exa fallback, limit lines for speed
export FZF_CTRL_T_OPTS="--preview '([[ -f {} ]] && (bat --style=numbers --color=always {} 2>/dev/null || cat {})) || \
  ([[ -d {} ]] && ( (command -v lsd >/dev/null 2>&1 && lsd -1 --color=always {}) || \
                   (command -v exa >/dev/null 2>&1 && exa -T --color=always --level=2 {}) || \
                   (tree -C {} | head -200) ))' --preview-window=right:55%:wrap"
# Directory (alt-c) preview: tree/lsd/exa fallback
export FZF_ALT_C_OPTS="--preview '(command -v lsd >/dev/null 2>&1 && lsd -1 --color=always {}) || \
  (command -v exa >/dev/null 2>&1 && exa -T --color=always --level=2 {}) || \
  (tree -C {} | head -200)' --preview-window=right:55%:wrap"

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
