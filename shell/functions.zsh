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
