#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🚀 MISE TOOL SYNC                                                           #
#   -----------------                                                           #
#   Shows active tools, upgrades them, and prunes old ones.                     #
#   Zero arguments. Always performs full sync.                                  #
#                                                                              #
################################################################################

set -euo pipefail

source "$MY/core/utils/ui-kit.zsh"

if ! command -v mise >/dev/null 2>&1; then
  ui_error_simple "mise not installed (brew install mise)"
  exit 1
fi

ui_section "${UI_ICON_TOOLS} mise tool sync"
ui_subsection "Resolved Active Tools"
if ! mise current >/dev/null 2>&1; then
  ui_warning_simple "No active tools resolved (check mise config)."
else
  mise current
fi

ui_spacer
ui_subsection "Upgrading"
if ! mise upgrade >/dev/null 2>&1; then
  ui_error_simple "Upgrade failed"
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
ui_success_simple "mise sync complete" 1
