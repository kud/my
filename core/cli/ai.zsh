#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🤖 AI MANAGER                                                              #
#   -------------                                                              #
#   Manages AI assets and client configurations.                              #
#                                                                              #
#   Usage:                                                                     #
#     my ai sync                      Symlink agents/skills into ~/.claude/   #
#     my ai client <name>             Configure a specific AI client          #
#     my ai client [--force]          Configure all AI clients                #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh
source $MY/core/utils/ui-kit.zsh

# List of available AI clients
declare -a ai_clients=(
    "claude-code"
    "codex"
    "opencode"
    "github-copilot"
    "mistral-vibe"
)

case "$1" in

############################################################
# my ai sync
############################################################
sync)
    # Symlink AI assets (agents, skills) from $MY/ai/ and profile overrides
    # into tool-specific locations (~/.claude/).
    # Profile files override common ones when names collide.

    for asset_type in agents skills; do
      target_dir="$HOME/.claude/$asset_type"
      common_dir="$MY/ai/$asset_type"
      profile_dir="$MY/profiles/$OS_PROFILE/ai/$asset_type"

      [[ -L "$target_dir" ]] && rm -f "$target_dir"
      mkdir -p "$target_dir"

      if [[ -d "$common_dir" ]]; then
        for f in "$common_dir"/*.md(N); do
          ln -sf "$f" "$target_dir/$(basename "$f")"
        done
      fi

      if [[ -n "$OS_PROFILE" && -d "$profile_dir" ]]; then
        for f in "$profile_dir"/*.md(N); do
          ln -sf "$f" "$target_dir/$(basename "$f")"
        done
      fi

      ui_success_simple "Linked .claude/$asset_type/"
    done
    ;;

############################################################
# my ai client [name] [--force]
############################################################
client)
    shift

    if [[ -n "$1" && "$1" != "--force" ]]; then
        client="$1"
        shift

        if [[ ! " ${ai_clients[@]} " =~ " ${client} " ]]; then
            ui_error_msg "Unknown AI client: $client" 0
            ui_info_simple "Available clients: ${(j:, :)ai_clients}" 0
            exit 1
        fi

        script="$MY/core/cli/${client}.zsh"

        if [[ ! -f "$script" ]]; then
            ui_error_msg "Script not found: $script" 0
            exit 1
        fi

        exec "$script" "$@"
    fi

    # No specific client — run all
    ui_section "Configuring All AI Clients"
    ui_spacer

    FORCE_MODE=0
    for arg in "$@"; do
        [[ "$arg" == "--force" ]] && FORCE_MODE=1 && break
    done

    if [[ $FORCE_MODE -eq 1 ]]; then
        ui_info_simple "Force mode enabled - will re-add existing servers" 0
        ui_spacer
    fi

    declare -a successful=()
    declare -a failed=()
    declare -a skipped=()

    for client in "${ai_clients[@]}"; do
        script="$MY/core/cli/${client}.zsh"

        if [[ ! -f "$script" ]]; then
            ui_warning_simple "Script not found: $script" 0
            skipped+=("$client")
            continue
        fi

        if [[ $FORCE_MODE -eq 1 ]]; then
            if "$script" --force 2>&1; then
                successful+=("$client")
            else
                failed+=("$client")
            fi
        else
            if "$script" 2>&1; then
                successful+=("$client")
            else
                failed+=("$client")
            fi
        fi
    done

    ui_section "Configuration Summary"
    ui_spacer

    [[ ${#successful[@]} -gt 0 ]] && ui_success_simple "Successfully configured: ${(j:, :)successful}" 0
    [[ ${#skipped[@]} -gt 0 ]] && ui_info_simple "Skipped: ${(j:, :)skipped}" 0

    if [[ ${#failed[@]} -gt 0 ]]; then
        ui_error_msg "Failed: ${(j:, :)failed}" 0
        ui_spacer
        exit 1
    fi

    ui_spacer
    ui_success_simple "All AI clients configured successfully!" 0
    ui_spacer
    ;;

############################################################
# Help / unknown
############################################################
*)
    echo "Usage: my ai <command>"
    echo ""
    echo "Commands:"
    echo "  sync                  Symlink agents/skills into ~/.claude/"
    echo "  client [name]         Configure AI client(s)"
    echo ""
    echo "Available clients: ${(j:, :)ai_clients}"
    exit 1
    ;;
esac
