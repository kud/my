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
