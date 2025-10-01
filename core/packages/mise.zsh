#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🚀 MISE TOOL SYNC                                                           #
#   -----------------                                                           #
#   Ensures configured tools are installed, then upgrades and prunes.           #
#   Single entrypoint: always performs full maintenance cycle.                  #
#                                                                              #
################################################################################

set -euo pipefail

source "$MY/core/utils/ui-kit.zsh"

if ! command -v mise >/dev/null 2>&1; then
  ui_error_simple "mise not installed (brew install mise)"
  exit 1
fi

ui_section "${UI_ICON_TOOLS} mise tool sync"

# Capture initial state (may be empty or fail silently)
BEFORE_STATE=$(mise current 2>/dev/null || true)

ui_subsection "Ensuring configured tools present"
if ! mise install; then
  ui_error_simple "Install step failed"
else
  ui_success_simple "Configured tools installed/verified"
fi

# Upgrade only if something actually outdated (saves time when fresh)
OUTDATED=$(mise outdated 2>/dev/null || true)
DID_UPGRADE=0
if [[ -n "$OUTDATED" ]]; then
  ui_spacer
  ui_subsection "Upgrading"
  if ! UPGRADE_OUTPUT=$(mise upgrade 2>&1); then
    ui_error_simple "Upgrade failed"
    echo "$UPGRADE_OUTPUT"
  else
    echo "$UPGRADE_OUTPUT" | grep -v '^$' || true
    ui_success_simple "Runtimes upgraded"
    DID_UPGRADE=1
  fi
fi

# Prune weekly (reduce churn) — stamp file strategy
STAMP_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/my/mise"
STAMP_FILE="$STAMP_DIR/last_prune"
mkdir -p "$STAMP_DIR"
NEED_PRUNE=0
if [[ ! -f "$STAMP_FILE" ]]; then
  NEED_PRUNE=1
else
  LAST=$(date -r "$STAMP_FILE" +%s 2>/dev/null || echo 0)
  NOW=$(date +%s)
  # 604800 seconds = 7 days
  (( NOW - LAST > 604800 )) && NEED_PRUNE=1
fi
if (( NEED_PRUNE )); then
  ui_spacer
  ui_subsection "Pruning (weekly)"
  if ! mise prune >/dev/null 2>&1; then
    ui_warning_simple "Prune failed"
  else
    ui_success_simple "Unused versions pruned"
    date +%s > "$STAMP_FILE" 2>/dev/null || true
  fi
fi

# Final state
AFTER_STATE=$(mise current 2>/dev/null || true)

ui_spacer
ui_subsection "Resolved Active Tools"
if [[ -z "$AFTER_STATE" ]]; then
  ui_warning_simple "No active tools resolved (check mise config)."
else
  # Build associative arrays to compute changes
  typeset -A before_map after_map
  while read -r name ver; do
    [[ -n "$name" && -n "$ver" ]] && before_map[$name]="$ver"
  done <<< "$BEFORE_STATE"
  while read -r name ver; do
    [[ -n "$name" && -n "$ver" ]] && after_map[$name]="$ver"
  done <<< "$AFTER_STATE"

  CHANGES=()
  for k in ${(k)after_map}; do
    if [[ -z ${before_map[$k]:-} ]]; then
      CHANGES+="+ $k ${after_map[$k]}"
    elif [[ ${before_map[$k]} != ${after_map[$k]} ]]; then
      CHANGES+="~ $k ${before_map[$k]} -> ${after_map[$k]}"
    fi
  done
  for k in ${(k)before_map}; do
    if [[ -z ${after_map[$k]:-} ]]; then
      CHANGES+="- $k ${before_map[$k]}"
    fi
  done

  if (( ${#CHANGES[@]} > 0 )); then
    ui_info_simple "Runtime changes:" 
    for line in ${CHANGES[@]}; do
      ui_muted "  $line"
    done
  else
    ui_muted "No runtime changes"
  fi

  # Always show final concise list
  echo "$AFTER_STATE"
fi

ui_spacer
ui_success_simple "mise maintenance complete" 1
