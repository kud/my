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
