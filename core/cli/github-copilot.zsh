#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🤖 GITHUB COPILOT MCP CONFIGURATOR                                         #
#   -----------------------------------                                        #
#   Generates ~/.copilot/mcp-config.json from config/cli/github-copilot.yml   #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh
source $MY/core/utils/ui-kit.zsh
source $MY/shell/globals.zsh

ui_subsection "Configuring GitHub Copilot MCP"

# Check if yq is available
if ! command -v yq >/dev/null 2>&1; then
    ui_error_msg "yq not found. Install with: brew install yq" 1
    return 1
fi

# Get current profile
PROFILE="${OS_PROFILE:-default}"

# Define config file paths
COMMON_CONFIG="$MY/config/cli/github-copilot.yml"
PROFILE_CONFIG="$MY/profiles/$PROFILE/config/cli/github-copilot.yml"
MCP_OUTPUT_FILE="$HOME/.copilot/mcp-config.json"
CONFIG_OUTPUT_FILE="$HOME/.copilot/config.json"

# Create output directory
mkdir -p "$(dirname "$MCP_OUTPUT_FILE")"

# Generate config by merging common and profile-specific configs
if [[ -f "$COMMON_CONFIG" ]]; then
    if [[ -n "$PROFILE_CONFIG" && -f "$PROFILE_CONFIG" ]]; then
        # Merge common and profile configs
        yq eval-all '. as $item ireduce ({}; . *+ $item)' \
            "$COMMON_CONFIG" "$PROFILE_CONFIG" -o=json > /tmp/copilot-merged.json
    else
        # Only common config
        yq eval -o=json "$COMMON_CONFIG" > /tmp/copilot-merged.json
    fi
    
    # Merge config settings (banner, etc.) into existing config.json
    if yq eval '.config' /tmp/copilot-merged.json >/dev/null 2>&1; then
        # Extract new config from merged YAML
        yq eval '.config' -o=json /tmp/copilot-merged.json > /tmp/copilot-new-config.json

        # Merge with existing config.json if it exists
        if [[ -f "$CONFIG_OUTPUT_FILE" ]]; then
            yq eval-all '. as $item ireduce ({}; . *+ $item)' \
                "$CONFIG_OUTPUT_FILE" /tmp/copilot-new-config.json -o=json > /tmp/copilot-final-config.json
            mv /tmp/copilot-final-config.json "$CONFIG_OUTPUT_FILE"
        else
            mv /tmp/copilot-new-config.json "$CONFIG_OUTPUT_FILE"
        fi

        # Clean up temp file
        rm -f /tmp/copilot-new-config.json
    fi
    
    # Extract mcpServers to mcp-config.json
    yq eval '. | {"mcpServers": .mcpServers}' -o=json /tmp/copilot-merged.json > "$MCP_OUTPUT_FILE"

    # Clean up temp file
    rm -f /tmp/copilot-merged.json

    # Substitute environment variables in the final JSON files
    if command -v envsubst >/dev/null 2>&1; then
        # Use envsubst to replace ${VAR} patterns with actual values
        envsubst < "$MCP_OUTPUT_FILE" > /tmp/copilot-mcp-subst.json
        mv /tmp/copilot-mcp-subst.json "$MCP_OUTPUT_FILE"

        if [[ -f "$CONFIG_OUTPUT_FILE" ]]; then
            envsubst < "$CONFIG_OUTPUT_FILE" > /tmp/copilot-config-subst.json
            mv /tmp/copilot-config-subst.json "$CONFIG_OUTPUT_FILE"
        fi
    else
        ui_warning_simple "envsubst not found, environment variables will not be expanded" 0
        ui_info_simple "Install with: brew install gettext" 0
    fi
    
    # Validate JSON outputs
    if [[ -f "$MCP_OUTPUT_FILE" ]] && python3 -m json.tool "$MCP_OUTPUT_FILE" >/dev/null 2>&1; then
        # Show configured servers
        local server_count=$(yq eval '.mcpServers | keys | length' -o=json "$MCP_OUTPUT_FILE")
        local servers=$(yq eval '.mcpServers | keys | .[]' -o=json "$MCP_OUTPUT_FILE" | tr '\n' ' ')
        
        echo ""
        ui_success_simple "GitHub Copilot MCP configuration complete" 0
        ui_info_simple "Config file: $CONFIG_OUTPUT_FILE" 0
        ui_info_simple "MCP config: $MCP_OUTPUT_FILE" 0
        ui_info_simple "MCP servers ($server_count): $servers" 0
    else
        ui_error_msg "Failed to generate valid JSON config" 1
        return 1
    fi
else
    ui_error_msg "GitHub Copilot config not found: $COMMON_CONFIG" 1
    return 1
fi

ui_spacer
