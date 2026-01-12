#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🤖 AI CLIENT CONFIGURATOR                                                  #
#   -----------------------                                                    #
#   Runs all AI client configuration scripts to update MCP servers and        #
#   settings across Claude Code, Codex, OpenCode, GitHub Copilot, and         #
#   Mistral Vibe.                                                              #
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

# If a specific client is specified, run just that one
if [[ -n "$1" && "$1" != "--force" ]]; then
    client="$1"
    shift

    # Check if it's a valid client
    if [[ ! " ${ai_clients[@]} " =~ " ${client} " ]]; then
        ui_error_msg "Unknown AI client: $client" 0
        ui_info_simple "Available clients: ${(j:, :)ai_clients}" 0
        exit 1
    fi

    # Run the specific client configuration
    script="$MY/core/cli/${client}.zsh"

    if [[ ! -f "$script" ]]; then
        ui_error_msg "Script not found: $script" 0
        exit 1
    fi

    exec "$script" "$@"
fi

# Otherwise, run all AI clients
ui_section "Configuring All AI Clients"
ui_spacer

# Parse command line arguments
FORCE_MODE=0
for arg in "$@"; do
    if [[ "$arg" == "--force" ]]; then
        FORCE_MODE=1
        break
    fi
done

# Show force mode status
if [[ $FORCE_MODE -eq 1 ]]; then
    ui_info_simple "Force mode enabled - will re-add existing servers" 0
    ui_spacer
fi

# Track success/failure
declare -a successful=()
declare -a failed=()
declare -a skipped=()

# Run each AI client configuration
for client in "${ai_clients[@]}"; do
    script="$MY/core/cli/${client}.zsh"

    if [[ ! -f "$script" ]]; then
        ui_warning_simple "Script not found: $script" 0
        skipped+=("$client")
        continue
    fi

    # Run the configuration script, passing through --force if set
    # (each script prints its own header)
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

# Summary
ui_section "Configuration Summary"
ui_spacer

if [[ ${#successful[@]} -gt 0 ]]; then
    ui_success_simple "Successfully configured: ${(j:, :)successful}" 0
fi

if [[ ${#skipped[@]} -gt 0 ]]; then
    ui_info_simple "Skipped: ${(j:, :)skipped}" 0
fi

if [[ ${#failed[@]} -gt 0 ]]; then
    ui_error_msg "Failed: ${(j:, :)failed}" 0
    ui_spacer
    exit 1
fi

ui_spacer
ui_success_simple "All AI clients configured successfully!" 0
ui_spacer
