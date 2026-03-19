################################################################################
#                                                                              #
#   🔧 SHELL FUNCTIONS                                                         #
#   ----------------                                                           #
#   Custom shell functions for enhanced productivity and navigation.          #
#                                                                              #
################################################################################

# Load UI kit for icon variables
source "$MY/core/utils/ui-kit.zsh"

# 🏷️ Tab title: auto or manual
_custom_title=""

_acronyms=(MCP PR CI CD QA API CLI TUI UI DB AWS GCP HTTP HTTPS CSS JS TS)

_fix_acronyms() {
  local s="$1"
  for a in $_acronyms; do
    s="${s//${(C)a}/$a}"
  done
  echo "$s"
}

_tab_title() {
  [[ "$PWD" == "$HOME" ]] && echo "" && return
  [[ "$PWD" == "$MY/profiles/"* ]] && echo "My · $(_fix_acronyms "${(C)${${PWD#$MY/profiles/}%%/*}:gs/-/ /}")" && return
  [[ "$PWD" == */my-profile-* ]] && echo "My · $(_fix_acronyms "${(C)${${PWD##*/my-profile-}%%/*}:gs/-/ /}")" && return
  local git_root
  git_root=$(git rev-parse --show-toplevel 2>/dev/null)
  local name="${${git_root:-$PWD}##*/}"
  [[ "$PWD" == $HOME/__tmp* || "$git_root" == $HOME/__tmp* ]] && echo "󰦖" && return
  _fix_acronyms "${(C)${name:gs/-/ /}}"
}

precmd() {
  local title="${_custom_title:-$(_tab_title)}"
  echo -ne "\e]1;$title\a"
}


title() {
  _custom_title="$*"
  [[ -n "$*" ]] && iterm title "$*" || precmd
}

claude() {
  local prev="$_custom_title"
  local project="${_custom_title:-$(_tab_title)}"
  _custom_title="$project · Claude 🤖"
  precmd

  local brew_output
  brew_output=$(HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade claude-code 2>&1)

  if echo "$brew_output" | grep -q "Not upgrading"; then
    echo "✓ up to date"
  else
    echo "✨ updated"
  fi
  echo

  command claude "$@"
  _custom_title="$prev"
  precmd
}

copiloted-claude() {
  if ! lsof -i :4141 -sTCP:LISTEN -t &>/dev/null; then
    copilot-api start &>/dev/null &
  fi
  env -u ANTHROPIC_API_KEY \
  ANTHROPIC_BASE_URL=http://localhost:4141 \
  ANTHROPIC_MODEL=claude-sonnet-4.6 \
    command claude "$@"
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

