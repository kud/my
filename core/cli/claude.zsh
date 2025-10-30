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
        ui_success_simple "Updated setting: $key = $value" 0
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

    # Check if already configured
    if claude mcp list 2>&1 | grep -q "$name"; then
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

        if [[ "$transport" == "stdio" ]]; then
            # For stdio transport, read command and args
            command=$(yq -r ".mcp.$name.command" "$COMMON_CONFIG" 2>/dev/null)
            command=$(expand_env_vars "$command")
            local args=()
            local arg_values=($(yq -r ".mcp.$name.args[]" "$COMMON_CONFIG" 2>/dev/null))
            for arg in "${arg_values[@]}"; do
                args+=("$(expand_env_vars "$arg")")
            done

            # Read environment variables if they exist
            local env_vars=()
            local env_keys=($(yq -r ".mcp.$name.env | keys[]" "$COMMON_CONFIG" 2>/dev/null))
            for key in "${env_keys[@]}"; do
                value=$(yq -r ".mcp.$name.env.$key" "$COMMON_CONFIG" 2>/dev/null)
                value=$(expand_env_vars "$value")
                env_vars+=("$key=$value")
            done

            if [[ -n "$transport" && -n "$command" ]]; then
                add_mcp_server "$name" "$transport" "$command" "${args[@]}" "${env_vars[@]}"
            fi
        else
            # For http/sse transport, read url and headers
            url=$(yq -r ".mcp.$name.url" "$COMMON_CONFIG" 2>/dev/null)
            url=$(expand_env_vars "$url")

            # Read headers if they exist
            local headers=()
            local header_keys=($(yq -r ".mcp.$name.headers | keys[]" "$COMMON_CONFIG" 2>/dev/null))
            for key in "${header_keys[@]}"; do
                value=$(yq -r ".mcp.$name.headers.$key" "$COMMON_CONFIG" 2>/dev/null)
                value=$(expand_env_vars "$value")
                headers+=("$key: $value")
            done

            if [[ -n "$transport" && -n "$url" ]]; then
                add_mcp_server "$name" "$transport" "$url" "${headers[@]}"
            fi
        fi
    done
fi

# Process profile-specific MCP servers (if config exists)
if [[ -f "$PROFILE_CONFIG" ]]; then
    # Read profile-specific MCP servers from YAML
    mcp_names=($(yq -r '.mcp | keys[]' "$PROFILE_CONFIG" 2>/dev/null))

    for name in "${mcp_names[@]}"; do
        transport=$(yq -r ".mcp.$name.transport" "$PROFILE_CONFIG" 2>/dev/null)

        if [[ "$transport" == "stdio" ]]; then
            # For stdio transport, read command and args
            command=$(yq -r ".mcp.$name.command" "$PROFILE_CONFIG" 2>/dev/null)
            command=$(expand_env_vars "$command")
            local args=()
            local arg_values=($(yq -r ".mcp.$name.args[]" "$PROFILE_CONFIG" 2>/dev/null))
            for arg in "${arg_values[@]}"; do
                args+=("$(expand_env_vars "$arg")")
            done

            # Read environment variables if they exist
            local env_vars=()
            local env_keys=($(yq -r ".mcp.$name.env | keys[]" "$PROFILE_CONFIG" 2>/dev/null))
            for key in "${env_keys[@]}"; do
                value=$(yq -r ".mcp.$name.env.$key" "$PROFILE_CONFIG" 2>/dev/null)
                value=$(expand_env_vars "$value")
                env_vars+=("$key=$value")
            done

            if [[ -n "$transport" && -n "$command" ]]; then
                add_mcp_server "$name" "$transport" "$command" "${args[@]}" "${env_vars[@]}"
            fi
        else
            # For http/sse transport, read url and headers
            url=$(yq -r ".mcp.$name.url" "$PROFILE_CONFIG" 2>/dev/null)
            url=$(expand_env_vars "$url")

            # Read headers if they exist
            local headers=()
            local header_keys=($(yq -r ".mcp.$name.headers | keys[]" "$PROFILE_CONFIG" 2>/dev/null))
            for key in "${header_keys[@]}"; do
                value=$(yq -r ".mcp.$name.headers.$key" "$PROFILE_CONFIG" 2>/dev/null)
                value=$(expand_env_vars "$value")
                headers+=("$key: $value")
            done

            if [[ -n "$transport" && -n "$url" ]]; then
                add_mcp_server "$name" "$transport" "$url" "${headers[@]}"
            fi
        fi
    done
fi
