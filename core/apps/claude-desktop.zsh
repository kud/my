#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🤖 CLAUDE DESKTOP CONFIGURATOR                                             #
#   -------------------------------                                            #
#   Configures Claude Desktop with profile-specific MCP servers               #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh
source $MY/core/utils/ui-kit.zsh

# Handle show-config subcommand
if [[ "$1" == "show-config" ]]; then
    ui_subtitle "Claude Desktop Config:"

    config_file="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

    if [[ -f "$config_file" ]]; then
        ui_info_simple "$config_file" 0
    else
        ui_warning_simple "$config_file (not found)" 0
    fi
    ui_spacer
    return 0
fi

ui_subsection "Configuring Claude Desktop"

# Define Claude Desktop config path
CLAUDE_DESKTOP_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

# Get current profile
PROFILE="${OS_PROFILE:-default}"

# Define config file paths
COMMON_CONFIG="$MY/config/apps/claude-desktop.yml"
PROFILE_CONFIG="$MY/profiles/$PROFILE/config/apps/claude-desktop.yml"

# Check if jq is available
if ! command -v jq >/dev/null 2>&1; then
    ui_error_msg "jq not found. Install with: brew install jq" 1
    return 1
fi

# Check if yq is available
if ! command -v yq >/dev/null 2>&1; then
    ui_error_msg "yq not found. Install with: brew install yq" 1
    return 1
fi

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
    eval echo "$text"
}

# Initialize config directory
mkdir -p "$(dirname "$CLAUDE_DESKTOP_CONFIG")"

# Start with empty mcpServers object
typeset -A mcp_servers_json
mcp_servers_json=()

# Function to build MCP server configuration
build_mcp_server() {
    local name="$1"
    local transport="$2"
    shift 2

    if [[ "$transport" == "stdio" ]]; then
        local command="$1"
        shift
        local args=("$@")

        # Check for environment variables (KEY=VALUE format)
        local cmd_args=()
        local has_env=false
        local env_vars="{}"

        for arg in "${args[@]}"; do
            if [[ "$arg" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
                # This is an environment variable
                local key="${arg%%=*}"
                local value="${arg#*=}"
                env_vars=$(echo "$env_vars" | jq --arg k "$key" --arg v "$value" '. + {($k): $v}')
                has_env=true
            else
                # This is a command argument
                cmd_args+=("$arg")
            fi
        done

        # Build stdio server config - only include env if it has values
        if [[ "$has_env" == "true" ]]; then
            mcp_servers_json[$name]=$(jq -n \
                --arg cmd "$command" \
                --argjson args "$(printf '%s\n' "${cmd_args[@]}" | jq -R . | jq -s .)" \
                --argjson env "$env_vars" \
                '{command: $cmd, args: $args, env: $env}')
        else
            mcp_servers_json[$name]=$(jq -n \
                --arg cmd "$command" \
                --argjson args "$(printf '%s\n' "${cmd_args[@]}" | jq -R . | jq -s .)" \
                '{command: $cmd, args: $args}')
        fi

        ui_success_simple "Added MCP server: $name" 0
    fi
}

# Process common MCP servers (if config exists)
if [[ -f "$COMMON_CONFIG" ]]; then
    mcp_names=($(yq -r '.mcp | keys[]' "$COMMON_CONFIG" 2>/dev/null))

    for name in "${mcp_names[@]}"; do
        transport=$(yq -r ".mcp.$name.transport" "$COMMON_CONFIG" 2>/dev/null)

        if [[ "$transport" == "stdio" ]]; then
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
            local env_validation_failed=0

            for key in "${env_keys[@]}"; do
                value=$(yq -r ".mcp.$name.env.$key" "$COMMON_CONFIG" 2>/dev/null)

                if ! check_env_vars "$value"; then
                    ui_warning_simple "Skipping MCP server '$name' due to missing environment variables" 0
                    env_validation_failed=1
                    break
                fi

                value=$(expand_env_vars "$value")
                env_vars+=("$key=$value")
            done

            if [[ $env_validation_failed -eq 0 && -n "$transport" && -n "$command" ]]; then
                build_mcp_server "$name" "$transport" "$command" "${args[@]}" "${env_vars[@]}"
            fi
        fi
    done
fi

# Process profile-specific MCP servers (if config exists)
if [[ -f "$PROFILE_CONFIG" ]]; then
    mcp_names=($(yq -r '.mcp | keys[]' "$PROFILE_CONFIG" 2>/dev/null))

    for name in "${mcp_names[@]}"; do
        transport=$(yq -r ".mcp.$name.transport" "$PROFILE_CONFIG" 2>/dev/null)

        if [[ "$transport" == "stdio" ]]; then
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
            local env_validation_failed=0

            for key in "${env_keys[@]}"; do
                value=$(yq -r ".mcp.$name.env.$key" "$PROFILE_CONFIG" 2>/dev/null)

                if ! check_env_vars "$value"; then
                    ui_warning_simple "Skipping MCP server '$name' due to missing environment variables" 0
                    env_validation_failed=1
                    break
                fi

                value=$(expand_env_vars "$value")
                env_vars+=("$key=$value")
            done

            if [[ $env_validation_failed -eq 0 && -n "$transport" && -n "$command" ]]; then
                build_mcp_server "$name" "$transport" "$command" "${args[@]}" "${env_vars[@]}"
            fi
        fi
    done
fi

# Build final JSON with all MCP servers
mcp_servers_object="{"
first=true
for name in "${(@k)mcp_servers_json}"; do
    if [[ "$first" == "true" ]]; then
        first=false
    else
        mcp_servers_object+=","
    fi
    mcp_servers_object+="\"$name\":${mcp_servers_json[$name]}"
done
mcp_servers_object+="}"

# Read existing config or start with empty object
if [[ -f "$CLAUDE_DESKTOP_CONFIG" ]]; then
    existing_config=$(cat "$CLAUDE_DESKTOP_CONFIG")
else
    existing_config="{}"
fi

# Replace only mcpServers section, preserving everything else
temp_file=$(mktemp)
echo "$existing_config" | jq --argjson servers "$mcp_servers_object" '.mcpServers = $servers' > "$temp_file" && mv "$temp_file" "$CLAUDE_DESKTOP_CONFIG"

ui_success_simple "Claude Desktop configuration complete" 1
ui_info_simple "Config file: $CLAUDE_DESKTOP_CONFIG" 1
