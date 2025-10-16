#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🚀 MISE TOOL MAINTENANCE                                                    #
#   -------------------------                                                   #
#   Full maintenance: update plugins, ensure tools, upgrade, prune, then        #
#   display the final resolved active runtimes list. No before/after diff.      #
#                                                                              #
################################################################################

set -euo pipefail

source "$MY/core/utils/ui-kit.zsh"

# Determine if the latest tag jumps to a new major release (e.g. 24 -> 25).
_mise_is_major_update() {
  local current="$1"
  local latest="$2"

  # Protect against empty or non-semver strings.
  [[ -z "${current:-}" || -z "${latest:-}" ]] && return 1

  local current_major="${current%%.*}"
  local latest_major="${latest%%.*}"

  if [[ "$current_major" == <-> && "$latest_major" == <-> ]]; then
    (( latest_major > current_major )) && return 0
  fi

  return 1
}

# Display available upstream runtime updates (including majors) for visibility.
_mise_show_outdated() {
  if ! command -v jq >/dev/null 2>&1; then
    local raw_output
    if raw_output=$(mise outdated --bump --no-header 2>&1); then
      if [[ -z "${raw_output// }" ]]; then
        ui_info_simple "All runtimes already match the latest upstream releases" 0
      else
        ui_info_simple "Updates available (install jq for richer output):" 0
        echo "$raw_output"
      fi
    else
      ui_warning_simple "Unable to check for upstream releases (jq missing, mise outdated failed)"
      ui_debug "mise outdated error: $raw_output"
    fi
    return
  fi

  local outdated_json
  if ! outdated_json=$(mise outdated --json --bump 2>&1); then
    ui_warning_simple "Unable to check for upstream releases"
    ui_debug "mise outdated error: $outdated_json"
    return
  fi

  local tool_count
  tool_count=$(printf "%s" "$outdated_json" | jq 'length')
  if [[ "$tool_count" == "0" ]]; then
    ui_info_simple "All runtimes already match the latest upstream releases" 0
    return
  fi

  printf "  %-14s %-12s %-12s %-12s %s\n" "Tool" "Requested" "Current" "Latest" "Notes"
  printf "%s" "$outdated_json" | jq -r 'to_entries[] | "\(.key)\t\(.value.requested // "-")\t\(.value.current // "-")\t\(.value.latest // "-")"' | while IFS=$'\t' read -r tool requested current latest; do
    local note=""
    if _mise_is_major_update "$current" "$latest"; then
      note="major release available"
    fi
    printf "  %-14s %-12s %-12s %-12s %s\n" "$tool" "$requested" "$current" "$latest" "$note"
  done
}

# --- Trap for nicer failure summary -------------------------------------------------
_mise_sync_fail() {
  local exit_code=$?
  if (( exit_code != 0 )); then
    ui_spacer
    ui_error_simple "mise maintenance failed (exit $exit_code)"
  fi
  exit $exit_code
}
trap _mise_sync_fail EXIT

if ! command -v mise >/dev/null 2>&1; then
  ui_error_simple "mise not installed (brew install mise)"
  exit 1
fi

ui_section "${UI_ICON_TOOLS} mise maintenance"

# Refresh plugin index (ensures latest runtime listings)
ui_subsection "Updating plugin index"
if ! mise plugins update >/dev/null 2>&1; then
  ui_warning_simple "Plugin index update failed"
else
  ui_success_simple "Plugin index updated"
fi

ui_spacer
ui_subsection "Checking upstream releases"
_mise_show_outdated

ui_spacer
ui_subsection "Ensuring configured tools present"
if ! mise install; then
  ui_error_simple "Install step failed"
  exit 1
else
  ui_success_simple "Configured tools installed/verified"
fi

ui_spacer
ui_subsection "Upgrading"
if ! mise upgrade; then
  ui_error_simple "Upgrade failed"
  exit 1
else
  ui_success_simple "Runtimes upgraded"
fi

ui_spacer
ui_subsection "Pruning"
if ! mise prune >/dev/null 2>&1; then
  ui_warning_simple "Prune failed"
else
  ui_success_simple "Unused versions pruned"
fi

ui_spacer
ui_subsection "Resolved Active Tools"
if ! FINAL_STATE=$(mise current 2>/dev/null); then
  ui_warning_simple "No active tools resolved (check mise config)."
else
  echo "$FINAL_STATE"
fi

ui_spacer
ui_success_simple "mise maintenance complete" 1

# Clear trap on success so EXIT handler does not double-report
trap - EXIT
