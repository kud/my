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

# Handle show-config subcommand
if [[ "$1" == "show-config" ]]; then
    ui_subtitle "Claude Code Config:"

    CLAUDE_CONFIG="$HOME/.claude.json"
    CLAUDE_SETTINGS="$HOME/.claude/settings.json"

    for config_file in "$CLAUDE_CONFIG" "$CLAUDE_SETTINGS"; do
        if [[ -f "$config_file" ]]; then
            ui_info_simple "$config_file" 0
        else
            ui_warning_simple "$config_file (not found)" 0
        fi
    done
    ui_spacer
    return 0
fi

ui_subsection "Configuring Claude Code"

# Check if Claude Code is installed
if ! command -v claude >/dev/null 2>&1; then
    ui_error_msg "Claude Code CLI not found. Install via: npm install -g @anthropic-ai/claude-code" 1
    return 1
fi

# Get current profile
PROFILE="${OS_PROFILE:-default}"

# Define config file paths
COMMON_CONFIG="$MY/config/cli/claude-code.yml"
PROFILE_CONFIG="$MY/profiles/$PROFILE/config/cli/claude-code.yml"
CLAUDE_CONFIG="$HOME/.claude.json"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"

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
        ui_success_simple "Updated setting: $key = $value" 0
    fi
}

# Function to update Claude UI settings (~/.claude/settings.json)
update_claude_ui_settings() {
    local key="$1"
    local value="$2"

    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$CLAUDE_SETTINGS")"

    # Initialize file if it doesn't exist
    if [[ ! -f "$CLAUDE_SETTINGS" ]]; then
        echo "{}" > "$CLAUDE_SETTINGS"
    fi

    # Check if jq is available
    if ! command -v jq >/dev/null 2>&1; then
        ui_warning_simple "jq not found, skipping UI settings update" 1
        return 0
    fi

    # Get current value
    local current_value=$(jq -r ".$key // empty" "$CLAUDE_SETTINGS" 2>/dev/null)

    # Only update if different
    if [[ "$current_value" != "$value" ]]; then
        # Create temp file with updated value
        local temp_file=$(mktemp)
        jq ".$key = $value" "$CLAUDE_SETTINGS" > "$temp_file" && mv "$temp_file" "$CLAUDE_SETTINGS"
        ui_success_simple "Updated UI setting: $key" 0
    fi
}

# Function to check if environment variables in a string are set
check_env_vars() {
    local text="$1"
    local missing_vars=()

    # Extract all ${VAR_NAME} patterns
    while [[ "$text" =~ \$\{([A-Za-z_][A-Za-z0-9_]*)\} ]]; do
        local var_name="${BASH_REMATCH[1]}"

        # Check if the variable is set
        if [[ -z "${(P)var_name}" ]]; then
            missing_vars+=("$var_name")
        fi

        # Remove the matched pattern to continue searching
        text="${text#*${BASH_REMATCH[0]}}"
    done

    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        for var in "${missing_vars[@]}"; do
            ui_error_msg "Environment variable \$$var is not set" 0
        done
        ui_error_msg "Please define the missing environment variables and try again" 0
        return 1
    fi

    return 0
}

# Function to expand environment variables in a string
expand_env_vars() {
    local text="$1"

    # Use eval to expand variables (safe because we validate them with check_env_vars first)
    eval echo "$text"
}

# Function to add MCP server
add_mcp_server() {
    local name="$1"
    local transport="$2"
    local url_or_command="$3"
    shift 3

    # Remaining args could be headers (for http/sse) or command args (for stdio)
    local extra_args=("$@")

    # Check if environment variables in URL/command are set
    if ! check_env_vars "$url_or_command"; then
        ui_error_msg "Cannot add MCP server '$name' due to missing environment variables" 0
        return 1
    fi

    # Check if environment variables in extra args are set
    for arg in "${extra_args[@]}"; do
        if ! check_env_vars "$arg"; then
            ui_error_msg "Cannot add MCP server '$name' due to missing environment variables" 0
            return 1
        fi
    done

    # Check if already configured using cached list
    if echo "$MCP_SERVER_LIST" | grep -q "$name"; then
        ui_info_simple "MCP server '$name' already configured" 0
        return 0
    fi

    # Build command based on transport type
    local cmd=(claude mcp add --scope user --transport "$transport" "$name")

    if [[ "$transport" == "stdio" ]]; then
        # For stdio, url_or_command is the command
        # Separate command args from env vars
        local cmd_args=()
        local env_vars=()

        for arg in "${extra_args[@]}"; do
            if [[ "$arg" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
                # This is an environment variable (KEY=VALUE)
                env_vars+=("$arg")
            else
                # This is a command argument
                cmd_args+=("$arg")
            fi
        done

        # Add environment variables with -e flag
        for env_var in "${env_vars[@]}"; do
            cmd+=(-e "$env_var")
        done

        # Add command and its arguments
        cmd+=(-- "$url_or_command")
        cmd+=("${cmd_args[@]}")
    else
        # For http/sse, url_or_command is the URL, extra_args are headers
        cmd+=("$url_or_command")
        for header in "${extra_args[@]}"; do
            cmd+=(-H "$header")
        done
    fi

    # Add the server (suppress all output)
    ui_debug_command "${cmd[@]}"
    local output
    output=$("${cmd[@]}" 2>&1)
    if [[ $? -eq 0 ]]; then
        ui_success_simple "Added MCP server: $name" 0
        return 0
    else
        ui_error_msg "Failed to add MCP server: $name" 0
        if [[ -n "$output" ]]; then
            ui_error_msg "  Claude CLI: $output" 0
        fi
        return 1
    fi
}

# Cache MCP server list once to avoid repeated calls
MCP_SERVER_LIST=$(claude mcp list 2>&1)

# Merge common + profile configs (profile overrides common, arrays are concatenated)
MERGED_CONFIG=$(mktemp)
if [[ -f "$COMMON_CONFIG" && -f "$PROFILE_CONFIG" ]]; then
    # Deep merge: profile values override common, arrays are appended (not replaced)
    yq eval-all '
        select(fileIndex == 0) *d select(fileIndex == 1)
        | .settings.permissions.allow = (
            ([select(fileIndex == 0) | .settings.permissions.allow // []] | .[0]) +
            ([select(fileIndex == 1) | .settings.permissions.allow // []] | .[0])
          | unique)
        | .settings.permissions.ask = (
            ([select(fileIndex == 0) | .settings.permissions.ask // []] | .[0]) +
            ([select(fileIndex == 1) | .settings.permissions.ask // []] | .[0])
          | unique)
        | .settings.permissions.deny = (
            ([select(fileIndex == 0) | .settings.permissions.deny // []] | .[0]) +
            ([select(fileIndex == 1) | .settings.permissions.deny // []] | .[0])
          | unique)
    ' "$COMMON_CONFIG" "$PROFILE_CONFIG" > "$MERGED_CONFIG" 2>/dev/null
elif [[ -f "$COMMON_CONFIG" ]]; then
    cp "$COMMON_CONFIG" "$MERGED_CONFIG"
elif [[ -f "$PROFILE_CONFIG" ]]; then
    cp "$PROFILE_CONFIG" "$MERGED_CONFIG"
fi

# Apply merged settings
if [[ -f "$MERGED_CONFIG" ]]; then
    # Read and apply all global settings from the global section
    global_setting_keys=($(yq -r '.global | keys[]' "$MERGED_CONFIG" 2>/dev/null))

    for key in "${global_setting_keys[@]}"; do
        value=$(yq -r ".global.$key" "$MERGED_CONFIG" 2>/dev/null)

        # Properly handle strings vs booleans/numbers
        if [[ "$value" =~ ^(true|false|[0-9]+)$ ]]; then
            update_claude_settings "$key" "$value"
        else
            update_claude_settings "$key" "\"$value\""
        fi
    done

    # Read and apply all settings from the settings section
    setting_keys=($(yq -r '.settings | keys[]' "$MERGED_CONFIG" 2>/dev/null))

    for key in "${setting_keys[@]}"; do
        # Check if the value is an object or array
        value_type=$(yq -r ".settings.$key | type" "$MERGED_CONFIG" 2>/dev/null)

        if [[ "$value_type" == "!!map" || "$value_type" == "!!seq" ]]; then
            # It's an object or array, output as JSON
            value=$(yq -o json ".settings.$key" "$MERGED_CONFIG" 2>/dev/null)
            update_claude_ui_settings "$key" "$value"
        else
            value=$(yq -r ".settings.$key" "$MERGED_CONFIG" 2>/dev/null)

            # Properly handle strings vs booleans/numbers
            if [[ "$value" =~ ^(true|false|[0-9]+)$ ]]; then
                update_claude_ui_settings "$key" "$value"
            else
                update_claude_ui_settings "$key" "\"$value\""
            fi
        fi
    done

    # Show statusLine preview if configured
    if [[ -f "$CLAUDE_SETTINGS" ]] && jq -e '.statusLine' "$CLAUDE_SETTINGS" >/dev/null 2>&1; then
        local status_type=$(jq -r '.statusLine.type' "$CLAUDE_SETTINGS" 2>/dev/null)
        if [[ "$status_type" == "command" ]]; then
            local status_cmd=$(jq -r '.statusLine.command' "$CLAUDE_SETTINGS" 2>/dev/null)
            local mock_input='{"workspace":{"current_dir":"'$PWD'"}}'
            local status_result=$(echo "$mock_input" | bash -c "$status_cmd" 2>/dev/null)
            ui_success_simple "Updated setting: statusLine = $status_result" 0
        fi
    fi
fi

# Process MCP servers from merged config
if [[ -f "$MERGED_CONFIG" ]]; then
    mcp_names=($(yq -r '.mcp | keys[]' "$MERGED_CONFIG" 2>/dev/null))

    for name in "${mcp_names[@]}"; do
        local enabled=$(yq -r ".mcp.$name.enabled" "$MERGED_CONFIG" 2>/dev/null)
        if [[ "$enabled" == "false" ]]; then
            if echo "$MCP_SERVER_LIST" | grep -q "$name"; then
                claude mcp remove "$name" --scope user >/dev/null 2>&1
                ui_success_simple "Removed MCP server: $name (disabled)" 0
            else
                ui_muted "MCP server '$name' (disabled)"
            fi
            continue
        fi

        transport=$(yq -r ".mcp.$name.transport" "$MERGED_CONFIG" 2>/dev/null)

        if [[ "$transport" == "stdio" ]]; then
            # For stdio transport, read command and args
            command=$(yq -r ".mcp.$name.command" "$MERGED_CONFIG" 2>/dev/null)
            command=$(expand_env_vars "$command")
            local args=()
            local arg_values=($(yq -r ".mcp.$name.args[]" "$MERGED_CONFIG" 2>/dev/null))
            for arg in "${arg_values[@]}"; do
                args+=("$(expand_env_vars "$arg")")
            done

            # Read environment variables if they exist
            local env_vars=()
            local env_keys=($(yq -r ".mcp.$name.env | keys[]" "$MERGED_CONFIG" 2>/dev/null))
            local env_validation_failed=0

            for key in "${env_keys[@]}"; do
                value=$(yq -r ".mcp.$name.env.$key" "$MERGED_CONFIG" 2>/dev/null)

                # Validate environment variables before expanding
                if ! check_env_vars "$value"; then
                    ui_warning_simple "Skipping MCP server '$name' due to missing environment variables" 0
                    env_validation_failed=1
                    break
                fi

                value=$(expand_env_vars "$value")
                env_vars+=("$key=$value")
            done

            if [[ $env_validation_failed -eq 0 && -n "$transport" && -n "$command" ]]; then
                add_mcp_server "$name" "$transport" "$command" "${args[@]}" "${env_vars[@]}"
            fi
        else
            # For http/sse transport, read url and headers
            url=$(yq -r ".mcp.$name.url" "$MERGED_CONFIG" 2>/dev/null)
            url=$(expand_env_vars "$url")

            # Read headers if they exist
            local headers=()
            local header_keys=($(yq -r ".mcp.$name.headers | keys[]" "$MERGED_CONFIG" 2>/dev/null))
            for key in "${header_keys[@]}"; do
                value=$(yq -r ".mcp.$name.headers.$key" "$MERGED_CONFIG" 2>/dev/null)
                value=$(expand_env_vars "$value")
                headers+=("$key: $value")
            done

            if [[ -n "$transport" && -n "$url" ]]; then
                add_mcp_server "$name" "$transport" "$url" "${headers[@]}"
            fi
        fi
    done
fi

# Clean up temp file
rm -f "$MERGED_CONFIG"

ui_success_simple "Claude Code configuration complete" 1
ui_info_simple "Config files: $CLAUDE_CONFIG, $CLAUDE_SETTINGS"
ui_spacer
