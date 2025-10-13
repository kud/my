#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🤖 CLAUDE CODE CONFIGURATOR                                                #
#   ----------------------------                                               #
#   Configures Claude Code CLI with profile-specific settings and MCP servers #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh
source $MY/core/utils/ui-kit.zsh

ui_subsection "Configuring Claude Code"

# Check if Claude Code is installed
if ! command -v claude >/dev/null 2>&1; then
    ui_error_msg "Claude Code CLI not found. Install via: npm install -g @anthropic-ai/claude-code" 1
    return 1
fi

# Get current profile
PROFILE="${OS_PROFILE:-default}"

# Define config file paths
COMMON_CONFIG="$MY/config/cli/claude.yml"
PROFILE_CONFIG="$MY/profiles/$PROFILE/config/cli/claude.yml"
CLAUDE_CONFIG="$HOME/.claude.json"

# Function to update Claude Code settings
update_claude_settings() {
    local key="$1"
    local value="$2"

    if [[ ! -f "$CLAUDE_CONFIG" ]]; then
        return 0
    fi

    # Check if jq is available
    if ! command -v jq >/dev/null 2>&1; then
        ui_warning_simple "jq not found, skipping settings update" 1
        return 0
    fi

    # Get current value
    local current_value=$(jq -r ".$key // empty" "$CLAUDE_CONFIG" 2>/dev/null)

    # Only update if different
    if [[ "$current_value" != "$value" ]]; then
        # Create temp file with updated value
        local temp_file=$(mktemp)
        jq ".$key = $value" "$CLAUDE_CONFIG" > "$temp_file" && mv "$temp_file" "$CLAUDE_CONFIG"
        ui_success_simple "Updated setting: $key = $value" 1
    fi
}

# Function to add MCP server
add_mcp_server() {
    local name="$1"
    local transport="$2"
    local url="$3"

    # Check if already configured
    if claude mcp list 2>&1 | grep -q "$name"; then
        ui_info_simple "MCP server '$name' already configured" 1
        return 0
    fi

    # Add the server (suppress all output)
    local output
    output=$(claude mcp add --transport "$transport" "$name" "$url" 2>&1)
    if [[ $? -eq 0 ]]; then
        ui_success_simple "Added MCP server: $name" 1
        return 0
    else
        ui_error_msg "Failed to add MCP server: $name" 1
        return 1
    fi
}

# Apply common settings (if config exists)
if [[ -f "$COMMON_CONFIG" ]]; then
    # Read and apply all settings from the settings section
    setting_keys=($(yq -r '.settings | keys[]' "$COMMON_CONFIG" 2>/dev/null))

    for key in "${setting_keys[@]}"; do
        value=$(yq -r ".settings.$key" "$COMMON_CONFIG" 2>/dev/null)

        # Properly handle strings vs booleans/numbers
        if [[ "$value" =~ ^(true|false|[0-9]+)$ ]]; then
            update_claude_settings "$key" "$value"
        else
            update_claude_settings "$key" "\"$value\""
        fi
    done
fi

# Process common MCP servers (if config exists)
if [[ -f "$COMMON_CONFIG" ]]; then
    # Read common MCP servers from YAML
    mcp_names=($(yq -r '.mcp | keys[]' "$COMMON_CONFIG" 2>/dev/null))

    for name in "${mcp_names[@]}"; do
        transport=$(yq -r ".mcp.$name.transport" "$COMMON_CONFIG" 2>/dev/null)
        url=$(yq -r ".mcp.$name.url" "$COMMON_CONFIG" 2>/dev/null)

        if [[ -n "$transport" && -n "$url" ]]; then
            add_mcp_server "$name" "$transport" "$url"
        fi
    done
fi

# Process profile-specific MCP servers (if config exists)
if [[ -f "$PROFILE_CONFIG" ]]; then
    # Read profile-specific MCP servers from YAML
    mcp_names=($(yq -r '.mcp | keys[]' "$PROFILE_CONFIG" 2>/dev/null))

    for name in "${mcp_names[@]}"; do
        transport=$(yq -r ".mcp.$name.transport" "$PROFILE_CONFIG" 2>/dev/null)
        url=$(yq -r ".mcp.$name.url" "$PROFILE_CONFIG" 2>/dev/null)

        if [[ -n "$transport" && -n "$url" ]]; then
            add_mcp_server "$name" "$transport" "$url"
        fi
    done
fi
