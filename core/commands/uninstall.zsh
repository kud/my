#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🚨 SYSTEM UNINSTALLER                                                      #
#   -------------------                                                        #
#   ⚠️  DANGER: This script PERMANENTLY removes the entire development       #
#   environment including all configurations and the repository itself.       #
#                                                                              #
################################################################################

# Load helper functions if available, otherwise provide basic ones
[[ -f "$HOME/my/core/helper" ]] && source "$HOME/my/core/helper" || {
    echo_fail() { echo "❌ $1"; exit ${2:-1} }
    echo_warn() { echo "⚠️  $1" }
    echo_info() { echo "ℹ️  $1" }
    echo_success() { echo "✅ $1" }
}

echo_warn "🚨 CRITICAL WARNING: COMPLETE SYSTEM REMOVAL 🚨"
echo ""
echo_warn "This will PERMANENTLY DELETE:"
echo "  • The entire ~/my repository and all configurations"
echo "  • All dotfiles (.zshrc, .gitconfig, .vimrc, etc.)"
echo "  • All custom aliases, editor configs, and shell settings"
echo ""
echo_warn "⚠️  THIS ACTION CANNOT BE UNDONE! ⚠️"
echo ""

################################################################################
# 🛡️ SAFETY CONFIRMATION
################################################################################

echo_info "Type 'DELETE EVERYTHING' to confirm complete removal:"
read -r confirmation

if [[ "$confirmation" != "DELETE EVERYTHING" ]]; then
    echo_info "Uninstallation cancelled - no changes made"
    exit 0
fi

echo ""
echo_warn "Last chance! Are you absolutely sure? (yes/no):"
read -r final_confirmation

if [[ "$final_confirmation" != "yes" ]]; then
    echo_info "Uninstallation cancelled - no changes made"
    exit 0
fi

################################################################################
# 🗑️ REMOVAL PROCESS
################################################################################

echo ""
echo_warn "Proceeding with complete system removal..."
echo ""

# Remove the main repository
if [[ -d "$HOME/my" ]]; then
    echo_info "Removing ~/my repository..."
    rm -rf "$HOME/my"
    echo_success "Repository removed"
else
    echo_info "Repository not found - skipping"
fi

# Remove dotfiles
echo_info "Removing configuration dotfiles..."
rm -rf "$HOME/."{aliases,editorconfig,gemrc,gitconfig,gitconfig_local,gitignore_global,prettierrc.js,vimrc,zshrc,zshrc_local}
echo_success "Dotfiles removed"

################################################################################
# 🏁 COMPLETION
################################################################################

echo ""
echo_success "Complete system uninstallation finished"
echo_warn "Development environment has been completely removed"
echo_info "Consider restarting the terminal or run: exec \$SHELL"
