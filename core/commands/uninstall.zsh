#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🚨 SYSTEM UNINSTALLER                                                      #
#   -------------------                                                        #
#   ⚠️  DANGER: This script PERMANENTLY removes the entire development       #
#   environment including all configurations and the repository itself.       #
#                                                                              #
################################################################################


echo "🚨 CRITICAL WARNING: COMPLETE SYSTEM REMOVAL 🚨"
echo ""
echo "This will PERMANENTLY DELETE:"
echo "  • The entire ~/my repository and all configurations"
echo "  • All dotfiles (.zshrc, .gitconfig, .vimrc, etc.)"
echo "  • All custom aliases, editor configs, and shell settings"
echo ""
echo "⚠️  THIS ACTION CANNOT BE UNDONE! ⚠️"
echo ""

################################################################################
# 🛡️ SAFETY CONFIRMATION
################################################################################

echo "Type 'DELETE EVERYTHING' to confirm complete removal:"
read -r confirmation

if [[ "$confirmation" != "DELETE EVERYTHING" ]]; then
    echo "Uninstallation cancelled - no changes made"
    exit 0
fi

echo ""
echo "Last chance! Are you absolutely sure? (yes/no):"
read -r final_confirmation

if [[ "$final_confirmation" != "yes" ]]; then
    echo "Uninstallation cancelled - no changes made"
    exit 0
fi

################################################################################
# 🗑️ REMOVAL PROCESS
################################################################################

echo ""
echo "Proceeding with complete system removal..."
echo ""

# Remove the main repository
if [[ -d "$HOME/my" ]]; then
    echo "Removing ~/my repository..."
    rm -rf "$HOME/my"
else
    echo "Repository not found - skipping"
fi

# Remove dotfiles
echo "Removing configuration dotfiles..."
rm -rf "$HOME/."{aliases,editorconfig,gemrc,gitconfig,gitconfig_local,gitignore_global,prettierrc.js,vimrc,zshrc,zshrc_local}

################################################################################
# 🏁 COMPLETION
################################################################################

echo ""
echo "Complete system uninstallation finished"
echo "Development environment has been completely removed"
echo "Consider restarting the terminal or run: exec \$SHELL"
