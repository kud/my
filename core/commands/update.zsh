#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🔄 ENVIRONMENT UPDATE MANAGER                                              #
#   ----------------------------                                              #
#   Updates the entire development environment including repository,           #
#   packages, and configurations to the latest versions.                      #
#                                                                              #
################################################################################

# Source UI Kit for beautiful output
source $MY/core/utils/ui-kit.zsh

# Global Nerd Font icons now provided by ui-kit; no per-script overrides needed

# Source intro functions (without auto-running)
source $MY/core/utils/intro.zsh

# Always show animated intro for update
if [[ -z "$CI" ]] && [[ -t 1 ]]; then
    show_animated_intro
fi

################################################################################
# 📋 ENVIRONMENT INFO
################################################################################

# Get version info
MY_VERSION=$(git --git-dir="$MY/.git" describe --tags --always 2>/dev/null || echo "unknown")
HOSTNAME=$(hostname -s)
PROFILE="${OS_PROFILE:-default}"

# Display environment info as a table for better readability
headers=$'Version	Host	Profile'
rows=$MY_VERSION$'\t'$HOSTNAME$'\t'$PROFILE
ui_table "$headers" "$rows"

ui_spacer

################################################################################
# 📦 PROJECT SYNCHRONIZATION
################################################################################

ui_section "  Updating repository"
ui_info_simple "Path: $MY"

if ! git -C "$MY" diff --quiet 2>/dev/null || ! git -C "$MY" diff --cached --quiet 2>/dev/null; then
    ui_error_simple "Uncommitted changes detected — stash or commit before updating"
    exit 1
fi

if ! git -C "$MY" fetch origin 2>/dev/null; then
    ui_error_simple "Failed to fetch from remote"
    exit 1
fi

local unpushed=$(git -C "$MY" rev-list origin/main..HEAD --count 2>/dev/null)
if [[ "$unpushed" -gt 0 ]]; then
    ui_error_simple "$unpushed unpushed commit(s) detected — push before updating"
    exit 1
fi

local before_hash=$(git -C "$MY" rev-parse HEAD 2>/dev/null)

git -C "$MY" reset --hard origin/main 2>/dev/null
git -C "$MY" fetch --tags --force 2>/dev/null

local after_hash=$(git -C "$MY" rev-parse HEAD 2>/dev/null)

if [[ "$before_hash" == "$after_hash" ]]; then
    ui_success_simple "Repository already up to date"
else
    ui_success_simple "Repository updated"
fi

# Update profile
if [[ -n "$OS_PROFILE" ]]; then
    local profile_dir="$MY/profiles/$OS_PROFILE"
    local github_user=$(git -C "$MY" remote get-url origin 2>/dev/null | sed 's|.*[:/]\([^/]*\)/.*|\1|')
    local profile_repo="git@github.com:${github_user}/my-profile-${OS_PROFILE}.git"

    if [[ -d "$profile_dir/.git" ]]; then
        ui_info_simple "Updating $OS_PROFILE profile..."
        git -C "$profile_dir" pull 2>&1
        if [[ $? -eq 0 ]]; then
            ui_success_simple "Profile '$OS_PROFILE' up to date"
        else
            ui_warning_simple "Failed to update profile"
        fi
    else
        ui_info_simple "Installing $OS_PROFILE profile..."
        git clone "$profile_repo" "$profile_dir"
    fi
fi

ui_spacer

################################################################################
# 🔧 ENVIRONMENT REFRESH
################################################################################

ui_section "  Updating environment"

# Run main update script (lightweight ensure during orchestration)
if ! $MY/core/main.zsh; then
    ui_error_msg "Environment update failed"
    exit 1
fi

# Full runtime maintenance already handled inside mise.zsh now; nothing extra here.

ui_spacer

################################################################################
# 🔄 MIGRATIONS
################################################################################

# Check for pending migrations first
pending_count=$($MY/core/system/migrations.zsh --check-only 2>/dev/null)
if [[ "$pending_count" -gt 0 ]]; then
    # Run migrations with full output
    if ! $MY/core/system/migrations.zsh; then
        ui_error_simple "Some migrations failed"
        ui_info_simple "Run 'my migrate --list' to see details"
        exit 1
    fi
    ui_spacer
fi


################################################################################
# 🆕 BREW UPDATE SUMMARY
################################################################################

brew_update_log="${TMPDIR:-/tmp}/my-brew-update.log"
if [[ -f "$brew_update_log" ]]; then
    new_formulae=$(awk '/^==> New Formulae/{f=1;next} /^==>/{f=0} f && NF{print "  "$0}' "$brew_update_log")
    new_casks=$(awk '/^==> New Casks/{f=1;next} /^==>/{f=0} f && NF{print "  "$0}' "$brew_update_log")
    new_formulae_full=$(awk '/^==> New Formulae/{f=1;next} /^==>/{f=0} f && NF{print}' "$brew_update_log")
    new_casks_full=$(awk '/^==> New Casks/{f=1;next} /^==>/{f=0} f && NF{print}' "$brew_update_log")
    outdated_formulae=$(awk '/^==> Outdated Formulae/{f=1;next} /^==>/{f=0} f && /^[a-z]/{n+=NF} END{print n+0}' "$brew_update_log")
    outdated_casks=$(awk '/^==> Outdated Casks/{f=1;next} /^==>/{f=0} f && /^[a-z]/{n+=NF} END{print n+0}' "$brew_update_log")

    if [[ -n "$new_formulae" ]] || [[ -n "$new_casks" ]] || [[ "$outdated_formulae" -gt 0 ]] || [[ "$outdated_casks" -gt 0 ]]; then
        ui_section "  Homebrew Summary"
        brew_label() { echo -e " ${UI_PRIMARY}${UI_ICON_STARTER}${UI_RESET} ${UI_BOLD_WHITE}$1${UI_RESET}"; }

        if [[ -n "$new_formulae" ]]; then
            brew_label "New Formulae"
            echo "$new_formulae" | while IFS= read -r line; do
                ui_info_simple "$line"
            done
        fi

        if [[ -n "$new_casks" ]]; then
            brew_label "New Casks"
            echo "$new_casks" | while IFS= read -r line; do
                ui_info_simple "$line"
            done
        fi

        if [[ "$outdated_formulae" -gt 0 ]] || [[ "$outdated_casks" -gt 0 ]]; then
            brew_label "Outdated"
            [[ "$outdated_formulae" -gt 0 ]] && ui_warning_simple "$outdated_formulae formula(e) available to upgrade"
            [[ "$outdated_casks" -gt 0 ]] && ui_warning_simple "$outdated_casks cask(s) available to upgrade"
        fi

        if [[ -n "$new_formulae_full" ]] || [[ -n "$new_casks_full" ]]; then
            brew_label "AI Digest"
            ai_prompt="You are a macOS developer assistant. Based on the new Homebrew packages below, highlight 2-4 that look genuinely interesting or useful for a developer, and briefly flag any to skip. Be concise and direct — no fluff.

New formulae:
${new_formulae_full:-none}

New casks:
${new_casks_full:-none}"
            ai_output=$(opencode run -m github-copilot/gpt-4.1 "$ai_prompt" 2>/dev/null)
            if [[ -n "$ai_output" ]]; then
                if command -v glow &>/dev/null; then
                    echo "$ai_output" | glow -
                else
                    echo "$ai_output"
                fi
            else
                ui_muted "  (opencode not available)"
            fi
        fi

        ui_spacer
    fi

    rm -f "$brew_update_log"
fi

################################################################################
# ✅ UPDATE COMPLETE
################################################################################

ui_primary "Update complete! "
