# ################################################################################
#                                                                                #
#   🚀 ZOXIDE INITIALISATION                                                     #
#   ----------------------                                                       #
#   Modern, fast directory jumping with frecency algorithm.                      #
#   https://github.com/ajeetdsouza/zoxide                                        #
#                                                                                #
# ################################################################################

# Smarter defaults for better results
# - Resolve symlinks to avoid duplicate entries of the same path
# - Ignore noisy/generated folders (node_modules, build, caches, etc.)
# - Provide rich FZF preview/navigation for the interactive picker
export _ZO_RESOLVE_SYMLINKS=1
export _ZO_MAXAGE=50000

# Glob patterns separated by ':'
# Note: Patterns are evaluated by zoxide (not the shell); '**' works regardless of zsh glob options
export _ZO_EXCLUDE_DIRS="$HOME/Library/**:$HOME/Library/Caches/**:$HOME/.cache/**:**/.git/**:**/node_modules/**:**/dist/**:**/build/**:/tmp/**:/private/tmp/**:/Volumes/**"

# Customize FZF used by `zoxide query -i`
# Keep this independent from global FZF_DEFAULT_OPTS to avoid conflicts
export _ZO_FZF_OPTS=${_ZO_FZF_OPTS:-"--height=40% --layout=reverse --inline-info --border --preview 'zsh -c '\''p=$1; if [[ -d "$p" ]]; then if command -v lsd >/dev/null 2>&1; then lsd -la --color=always -- "$p"; elif command -v exa >/dev/null 2>&1; then exa -la --color=always -- "$p"; else ls -la -- "$p"; fi; elif [[ -e "$p" ]]; then (command -v file >/dev/null 2>&1 && file -- "$p") || echo "$p"; else echo "⚠️  Missing or unreadable: $p"; fi 2>/dev/null || true'\'' -- {}' --preview-window=right:55%:wrap --bind alt-k:preview-up,alt-j:preview-down,ctrl-z:toggle-preview"}

if command -v zoxide >/dev/null 2>&1; then
  # Initialize zoxide and its `z` function
  eval "$(zoxide init zsh)"

  # Convenience interactive jump: zi → pick with FZF, then cd
  if [[ -o interactive ]]; then
    # A safe wrapper that cds into the selected result of `zoxide query -i`
    zi() {
      local dir
      dir=$(zoxide query -i -- "$@") || return
      [[ -n "$dir" ]] && cd -- "$dir"
    }

    # ZLE widget to trigger interactive jump without echoing commands
    _zoxide_fzf_widget() {
      local dir
      dir=$(zoxide query -i) || return
      [[ -n "$dir" ]] && cd -- "$dir"
      zle reset-prompt
    }
    zle -N _zoxide_fzf_widget

    # Keybinding: Alt-z opens interactive zoxide
    # (Esc z in terminals that don't send distinct Alt)
    bindkey '^[z' _zoxide_fzf_widget
  fi

    # Helper to prune stale entries from zoxide database
    zprune() {
      zoxide query -l | while IFS= read -r d; do
        [[ -d "$d" ]] || zoxide remove "$d"
      done
    }
fi
