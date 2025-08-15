#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🚨 SYSTEM UNINSTALLER                                                      #
#   -------------------                                                        #
#   ⚠️  DANGER: This script PERMANENTLY removes the entire development       #
#   environment including all configurations and the repository itself.       #
#                                                                              #
################################################################################

# Source UI Kit for beautiful output
source $MY/core/utils/ui-kit.zsh

# Critical warning display
ui_spacer 2
ui_divider "█" 60 "$UI_DANGER"
ui_center_text "🚨 CRITICAL WARNING: COMPLETE SYSTEM REMOVAL 🚨"
ui_divider "█" 60 "$UI_DANGER"
ui_spacer

ui_panel "PERMANENT DELETION WARNING" "This action will completely remove your development environment" "error"
ui_spacer

ui_danger "This will PERMANENTLY DELETE:"
ui_spacer
ui_muted "  • The entire ~/my repository and all configurations"
ui_muted "  • All dotfiles (.zshrc, .gitconfig, .vimrc, etc.)"
ui_muted "  • All custom aliases, editor configs, and shell settings"
ui_muted "  • All package manager configurations"
ui_spacer

ui_box "⚠️  THIS ACTION CANNOT BE UNDONE! ⚠️" "FINAL WARNING" 60
ui_spacer

################################################################################
# 🛡️ SAFETY CONFIRMATION
################################################################################

ui_divider "─" 60 "$UI_WARNING"
ui_warning_msg "Safety Confirmation Required"
ui_divider "─" 60 "$UI_WARNING"
ui_spacer

ui_error_simple "Type exactly 'DELETE EVERYTHING' to confirm:"
ui_spacer

# Use ui_input for confirmation
confirmation=$(ui_input "Confirmation phrase")

if [[ "$confirmation" != "DELETE EVERYTHING" ]]; then
    ui_spacer
    ui_success_msg "Uninstallation cancelled - no changes made"
    ui_muted "  Your system remains unchanged"
    ui_spacer
    exit 0
fi

ui_spacer
ui_warning_msg "Final confirmation required"

if ! ui_confirm "Are you absolutely sure you want to delete everything?"; then
    ui_spacer
    ui_success_msg "Uninstallation cancelled - no changes made"
    ui_muted "  Your system remains unchanged"
    ui_spacer
    exit 0
fi

################################################################################
# 🗑️ REMOVAL PROCESS
################################################################################

ui_spacer
ui_divider "─" 60 "$UI_DANGER"
ui_danger "Starting Complete System Removal"
ui_divider "─" 60 "$UI_DANGER"
ui_spacer

# Track removal progress
total_steps=2
current_step=0

# Remove the main repository
((current_step++))
ui_progress_bar $current_step $total_steps 40 "█" "░"
ui_spacer

if [[ -d "$HOME/my" ]]; then
    ui_warning_msg "Removing ~/my repository..."
    rm -rf "$HOME/my"
    ui_success_simple "Repository removed"
else
    ui_info_simple "Repository not found - skipping"
fi

ui_spacer

# Remove dotfiles
((current_step++))
ui_progress_bar $current_step $total_steps 40 "█" "░"
ui_spacer

ui_warning_msg "Removing configuration dotfiles..."
ui_spacer

dotfiles=(aliases editorconfig gemrc gitconfig gitconfig_local gitignore_global prettierrc.js vimrc zshrc zshrc_local)
removed_count=0

for file in "${dotfiles[@]}"; do
    if [[ -f "$HOME/.$file" ]]; then
        rm -f "$HOME/.$file"
        ui_muted "  Removed: ~/.$file"
        ((removed_count++))
    fi
done

if [[ $removed_count -gt 0 ]]; then
    ui_success_simple "Removed $removed_count configuration files"
else
    ui_info_simple "No dotfiles found to remove"
fi

################################################################################
# 🏁 COMPLETION
################################################################################

ui_spacer 2
ui_divider "═" 60 "$UI_SUCCESS"
ui_spacer

ui_badge "info" " UNINSTALLATION COMPLETE "
ui_spacer

ui_success_msg "Development environment has been completely removed"
ui_spacer

ui_info_simple "Next steps:"
ui_muted "  • Restart your terminal or run: exec \$SHELL"
ui_muted "  • Your system is now in its original state"
ui_muted "  • To reinstall, visit: github.com/kud/my"

ui_spacer
ui_primary "Thank you for using this development environment"
ui_spacer