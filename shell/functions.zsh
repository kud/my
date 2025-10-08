################################################################################
#                                                                              #
#   🔧 SHELL FUNCTIONS                                                         #
#   ----------------                                                           #
#   Custom shell functions for enhanced productivity and navigation.          #
#                                                                              #
################################################################################

# Load UI kit for icon variables
source "$MY/core/utils/ui-kit.zsh"

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

