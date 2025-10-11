#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "notify.sh expects a single JSON argument" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required to parse Codex notifications" >&2
  exit 0
fi

payload="$1"

mapfile -t parsed < <(python3 - "$payload" <<'PY'
import base64
import json
import sys

try:
    notification = json.loads(sys.argv[1])
except json.JSONDecodeError:
    print("parse-error")
    print("")
    print("")
    sys.exit(0)

note_type = notification.get("type", "")
assistant_message = notification.get("last-assistant-message") or notification.get("last_assistant_message")
inputs = notification.get("input-messages") or notification.get("input_messages") or []

if isinstance(inputs, list):
    message = " ".join(s for s in inputs if isinstance(s, str)).strip()
elif isinstance(inputs, str):
    message = inputs.strip()
else:
    message = ""

if not assistant_message:
    assistant_message = "Codex turn complete"

if not message:
    message = "Codex just finished running."

print(note_type)
print(base64.b64encode(assistant_message.encode("utf-8")).decode("ascii"))
print(base64.b64encode(message.encode("utf-8")).decode("ascii"))
PY
)

note_type="${parsed[0]:-}"

if [[ "$note_type" != "agent-turn-complete" ]]; then
  exit 0
fi

title="Codex Quest Complete ✨"
message="Mission accomplished! 🚀 Take a victory lap before the next command. 🏁"

play_sound() {
  local enable="${CODEX_NOTIFY_ENABLE_SOUND:-}"
  if [[ -n "$enable" ]]; then
    local enable_lc
    enable_lc=$(printf '%s' "$enable" | tr '[:upper:]' '[:lower:]')
    case "$enable_lc" in
      1|true|yes|on) ;;
      *) return ;;
    esac
  else
    return
  fi

  local sound="${CODEX_NOTIFY_SOUND:-}"

  if [[ -z "$sound" ]]; then
    if command -v afplay >/dev/null 2>&1; then
      sound="/System/Library/Sounds/Ping.aiff"
    elif command -v paplay >/dev/null 2>&1; then
      sound="/usr/share/sounds/freedesktop/stereo/complete.oga"
    elif command -v aplay >/dev/null 2>&1; then
      sound="/usr/share/sounds/alsa/Front_Center.wav"
    fi
  fi

  if [[ -n "$sound" ]]; then
    if command -v afplay >/dev/null 2>&1; then
      afplay "$sound" >/dev/null 2>&1 &
    elif command -v paplay >/dev/null 2>&1; then
      paplay "$sound" >/dev/null 2>&1 &
    elif command -v aplay >/dev/null 2>&1; then
      aplay "$sound" >/dev/null 2>&1 &
    fi
  fi
}

send_notification() {
  if command -v osascript >/dev/null 2>&1; then
    /usr/bin/osascript <<OSA >/dev/null 2>&1
display notification "$(printf '%s' "$message" | sed 's/"/\\"/g')" with title "$(printf '%s' "$title" | sed 's/"/\\"/g')"
OSA
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "$title" "$message" >/dev/null 2>&1
  fi
}

play_sound
send_notification
