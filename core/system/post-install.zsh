#!/usr/bin/env zsh
# 📮 Post-install documentation opener (minimal by request)
# Usage:
#   my run postinstall          # open GitHub doc in browser
#   my run postinstall --offline # open local markdown file

if [[ "$1" == "--offline" ]]; then
  # Open the local markdown file (relies on system default .md handler)
  open "$MY/doc/post-install.md" 2>/dev/null || {
    echo "Could not open local file: $MY/doc/post-install.md" >&2
    exit 1
  }
else
  open "https://github.com/kud/my/blob/master/doc/post-install.md"
fi
