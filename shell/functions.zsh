################################################################################
#                                                                              #
#   🔧 SHELL FUNCTIONS                                                         #
#   ----------------                                                           #
#   Custom shell functions for enhanced productivity and navigation.          #
#                                                                              #
################################################################################

# 🏷️ Tab title to current dir
precmd() {
  local title=""

  if [[ "$PWD" == "$HOME" ]]; then
    title="~"
  else
    title="${PWD##*/}"
  fi

  echo -ne "\e]1;$title\a"
}

# 📁 Create folder and cd into it
function mcd() {
  mkdir -p "$1" && cd "$1";
}

# 🗂️ Yazi: open and jump to selected dir
function yy() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# 🔍 Enhanced command inspector
function wtf() {
  local cmd="$1"

  if [[ -z "$cmd" ]]; then
    echo "Usage: wtf <command>"
    return 1
  fi

  # Show basic command info
  echo "🔍 Command: $cmd"
  echo "────────────────────"
  whence -v "$cmd" 2>/dev/null || echo "Command not found"
  echo

  # Package-specific intelligence
  case "$cmd" in
    npm)
      echo "📦 NPM Information:"
      echo "Version: $(npm --version 2>/dev/null || echo 'not installed')"
      echo "Location: $(which npm 2>/dev/null || echo 'not found')"
      echo "Registry: $(npm config get registry 2>/dev/null || echo 'unknown')"
      echo "Global packages location: $(npm root -g 2>/dev/null || echo 'unknown')"
      ;;
    node)
      echo "🟢 Node.js Information:"
      echo "Version: $(node --version 2>/dev/null || echo 'not installed')"
      echo "Location: $(which node 2>/dev/null || echo 'not found')"
      if command -v nvm >/dev/null 2>&1; then
        echo "NVM current: $(nvm current 2>/dev/null || echo 'unknown')"
      fi
      ;;
    python|python3|pip|pip3)
      echo "🐍 Python Information:"
      if [[ "$cmd" == "python" || "$cmd" == "python3" ]]; then
        echo "Version: $($cmd --version 2>/dev/null || echo 'not installed')"
        echo "Location: $(which $cmd 2>/dev/null || echo 'not found')"
      else
        echo "Version: $($cmd --version 2>/dev/null || echo 'not installed')"
        echo "Location: $(which $cmd 2>/dev/null || echo 'not found')"
      fi
      ;;
    brew)
      echo "🍺 Homebrew Information:"
      echo "Version: $(brew --version 2>/dev/null | head -1 || echo 'not installed')"
      echo "Location: $(which brew 2>/dev/null || echo 'not found')"
      echo "Prefix: $(brew --prefix 2>/dev/null || echo 'unknown')"
      ;;
    git)
      echo "📚 Git Information:"
      echo "Version: $(git --version 2>/dev/null || echo 'not installed')"
      echo "Location: $(which git 2>/dev/null || echo 'not found')"
      echo "Config user: $(git config --global user.name 2>/dev/null || echo 'not set')"
      ;;
    ruby|gem)
      echo "💎 Ruby Information:"
      if [[ "$cmd" == "ruby" ]]; then
        echo "Version: $(ruby --version 2>/dev/null || echo 'not installed')"
      else
        echo "Version: $(gem --version 2>/dev/null || echo 'not installed')"
      fi
      echo "Location: $(which $cmd 2>/dev/null || echo 'not found')"
      ;;
    *)
      # For other commands, show additional info if available
      if command -v "$cmd" >/dev/null 2>&1; then
        echo "ℹ️  Additional Information:"

        # Try to get version
        for flag in --version -v -V version; do
          if output=$($cmd $flag 2>/dev/null) && [[ -n "$output" ]]; then
            echo "Version: $(echo "$output" | head -1)"
            break
          fi
        done

        # Show file info
        local cmd_path=$(which "$cmd" 2>/dev/null)
        if [[ -n "$cmd_path" ]]; then
          echo "File type: $(file "$cmd_path" 2>/dev/null | cut -d: -f2- | sed 's/^ *//')"
          echo "Size: $(ls -lh "$cmd_path" 2>/dev/null | awk '{print $5}')"
        fi
      fi
      ;;
  esac
}

# 🤖 Install Android SDK components (latest platform by default or API level arg)
android-install() {
  local requested="$1" latest
  if [[ -z "$requested" || "$requested" == latest ]]; then
    latest=$(sdkmanager --list 2>/dev/null \
      | grep -Eo 'platforms;android-[0-9]+' \
      | sed 's/.*android-//' \
      | sort -n | uniq | tail -1)
    if [[ -z "$latest" ]]; then
      echo "android-install: could not determine latest platform" >&2
      return 1
    fi
  else
    latest="$requested"
  fi

  echo "Installing Android cmdline-tools;latest, platform $latest, emulator, platform-tools, tools" >&2
  sdkmanager "cmdline-tools;latest" "platforms;android-$latest" "emulator" "platform-tools" "tools"
}

# 🙏 Re-run last command with sudo (safer than simple alias)
please() {
  local last
  last=$(fc -ln -1)
  if [[ -z "$last" ]]; then
    echo "No previous command" >&2
    return 1
  fi
  printf 'sudo %s\n' "$last"
  sudo $SHELL -lc "$last"
}

# 🔎 FZF history search with Tokyonight color accents + icon
# Provides an improved Ctrl-R experience (non-destructive: only binds if available)
# Colorization is lightweight (keyword-based) to avoid the performance cost of invoking
# full zsh-syntax-highlighting per line. Adjust mappings or disable via FZF_HISTORY_SIMPLE=1
# Inspired by Tokyonight palette already defined in fzf.zsh; duplicates minimal colors
if command -v fzf >/dev/null 2>&1; then
  fzf-history-widget() {
    # Allow user override of icon and prompt text
    local icon=${FZF_HISTORY_ICON:-$''}   # Nerd Font magnifier (requires patched font)
    local prompt="${icon}  "

    # Base Tokyonight colors (24-bit); fall back gracefully if no truecolor
    # Use foreground-only reset so fzf selection background spans full width
    local C_RESET=$'\e[39m'
    local C_NUM=$'\e[38;2;86;95;137m'
    local C_DEFAULT=$'\e[38;2;192;202;245m'
    local C_GIT=$'\e[38;2;187;154;247m'
    local C_PKG=$'\e[38;2;158;206;106m'
    local C_BUILD=$'\e[38;2;255;158;100m'
    local C_NET=$'\e[38;2;125;207;255m'
    local C_SYS=$'\e[38;2;122;162;247m'

    # Precompute newest and oldest history (colored unless simple mode) for reload toggling
    local tmp_newest=$(mktemp -t fzf-hist-newest.XXXXXX)
    local tmp_oldest=$(mktemp -t fzf-hist-oldest.XXXXXX)
    if [[ -n ${FZF_HISTORY_SIMPLE:-} ]]; then
      builtin fc -rl 1 >| "$tmp_newest"
      builtin fc -l 1  >| "$tmp_oldest"
    else
      builtin fc -rl 1 | awk -v C_NUM="$C_NUM" -v C_RESET="$C_RESET" \
        -v C_DEFAULT="$C_DEFAULT" -v C_GIT="$C_GIT" -v C_PKG="$C_PKG" \
        -v C_BUILD="$C_BUILD" -v C_NET="$C_NET" -v C_SYS="$C_SYS" 'function colorize(cmd){
          if(cmd=="git") return C_GIT;
          if(cmd=="npm"||cmd=="pnpm"||cmd=="yarn"||cmd=="brew") return C_PKG;
          if(cmd=="make"||cmd=="cmake"||cmd=="cargo"||cmd=="go") return C_BUILD;
          if(cmd=="curl"||cmd=="wget"||cmd=="ssh"||cmd=="scp"||cmd=="kubectl"||cmd=="docker") return C_NET;
          if(cmd=="nvim"||cmd=="vim"||cmd=="code") return C_SYS;
          return C_DEFAULT;
        }
        {num=$1; $1=""; gsub(/^ +/, ""); line=$0; split(line,a," "); cmd=a[1]; clr=colorize(cmd); printf "%s%5s%s %s%s%s", C_NUM, num, C_RESET, clr, cmd, C_RESET; for(i=2;i<=length(a);i++){ printf " %s", a[i] }; printf "\033[0m\n" }' >| "$tmp_newest"
      builtin fc -l 1 | awk -v C_NUM="$C_NUM" -v C_RESET="$C_RESET" \
        -v C_DEFAULT="$C_DEFAULT" -v C_GIT="$C_GIT" -v C_PKG="$C_PKG" \
        -v C_BUILD="$C_BUILD" -v C_NET="$C_NET" -v C_SYS="$C_SYS" 'function colorize(cmd){
          if(cmd=="git") return C_GIT;
          if(cmd=="npm"||cmd=="pnpm"||cmd=="yarn"||cmd=="brew") return C_PKG;
          if(cmd=="make"||cmd=="cmake"||cmd=="cargo"||cmd=="go") return C_BUILD;
          if(cmd=="curl"||cmd=="wget"||cmd=="ssh"||cmd=="scp"||cmd=="kubectl"||cmd=="docker") return C_NET;
          if(cmd=="nvim"||cmd=="vim"||cmd=="code") return C_SYS;
          return C_DEFAULT;
        }
        {num=$1; $1=""; gsub(/^ +/, ""); line=$0; split(line,a," "); cmd=a[1]; clr=colorize(cmd); printf "%s%5s%s %s%s%s", C_NUM, num, C_RESET, clr, cmd, C_RESET; for(i=2;i<=length(a);i++){ printf " %s", a[i] }; printf "\033[0m\n" }' >| "$tmp_oldest"
    fi

    local selected
    # Pointer/marker shape (override with FZF_HISTORY_POINTER). Options: ▊ ▌ ▋ █  ➤ ▶ ❯
    local pointer_char=${FZF_HISTORY_POINTER:-$''}

    # Minimal selection style: remove wide highlight bar (bg+ same as bg)
    # Clear global FZF_DEFAULT_OPTS to avoid inherited bg+ and bold selection.
    local fzf_colors="--color=fg:#c0caf5,bg:-1,hl:#7dcfff,fg+:#c0caf5,bg+:-1,hl+:#bb9af7,prompt:#7aa2f7,pointer:#ff9e64,marker:#ff9e64,info:#565f89,border:#292e42,spinner:#bb9af7,header:#ff9e64"
    local header=${FZF_HISTORY_HEADER:-$'Alt-o oldest | Alt-n newest'}

    # Run fzf with newest-first initial feed; allow toggling ordering.
    selected=$(cat "$tmp_newest" | FZF_DEFAULT_OPTS="" fzf \
      --ansi --no-sort --query "$LBUFFER" \
      --prompt "$prompt" --height 40% --layout=reverse --inline-info \
      --bind "enter:accept" \
      --bind "alt-o:reload(cat $tmp_oldest)+first" \
      --bind "alt-n:reload(cat $tmp_newest)+first" \
      --no-bold \
      --pointer="$pointer_char" --marker="$pointer_char" \
      --header "$header" \
      $fzf_colors)
    local fzf_status=$?
    rm -f -- "$tmp_newest" "$tmp_oldest" || true
    (( fzf_status != 0 )) && return

    # Clean selection: strip ANSI escapes then leading history number
    if [[ -n $selected ]]; then
      selected=$(printf '%s' "$selected" | sed -E 's/\x1B\[[0-9;]*[A-Za-z]//g; s/^[[:space:]]*[0-9]+[[:space:]]+//')
      BUFFER=$selected
      CURSOR=$#BUFFER
      zle redisplay
    fi
  }
  zle -N fzf-history-widget
  # Rebind Ctrl-R to our widget (store old if needed)
  if [[ -z ${_ORIG_CTRL_R_BINDING:-} ]]; then
    _ORIG_CTRL_R_BINDING=$(bindkey '^R' | awk '{print $2}')
  fi
  bindkey '^R' fzf-history-widget
fi
