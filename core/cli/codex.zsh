#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🧠 CODEX CLI CONFIGURATOR                                                 #
#   -----------------------                                                    #
#   Configures Codex CLI with profile-specific settings and MCP servers       #
#   using the official `codex mcp add` command.                               #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh
source $MY/core/utils/ui-kit.zsh

ui_subsection "Configuring Codex CLI"

# Check if Codex CLI is installed
if ! command -v codex >/dev/null 2>&1; then
    ui_warning_simple "Codex CLI not found in PATH (npm install -g @openai/codex)" 1
    return 0
fi

# Get current profile
PROFILE="${OS_PROFILE:-default}"

# Define config file paths
COMMON_CONFIG="$MY/config/cli/codex.yml"
PROFILE_CONFIG="$MY/profiles/$PROFILE/config/cli/codex.yml"
CODEX_CONFIG_FILE="$HOME/.codex/config.toml"

# Ensure config directory exists
mkdir -p "$HOME/.codex"

# Function to configure features
configure_features() {
    local config_file="$1"

    # Read features from YAML
    local feature_keys=($(yq -r '.features | keys[]' "$config_file" 2>/dev/null))

    if [[ ${#feature_keys[@]} -eq 0 ]]; then
        return 0
    fi

    # Create a temporary file to build the new config
    local temp_file="${CODEX_CONFIG_FILE}.tmp"
    local in_features_section=0
    local features_section_found=0

    # If config file doesn't exist, create it with features section
    if [[ ! -f "$CODEX_CONFIG_FILE" ]]; then
        echo "[features]" > "$CODEX_CONFIG_FILE"
        for key in "${feature_keys[@]}"; do
            value=$(yq -r ".features.$key" "$config_file" 2>/dev/null)
            echo "$key = $value" >> "$CODEX_CONFIG_FILE"
            ui_success_simple "Set feature: $key = $value" 0
        done
        return 0
    fi

    # Read through existing config and update features
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Check if we're entering features section
        if [[ "$line" =~ ^\[features\] ]]; then
            in_features_section=1
            features_section_found=1
            echo "$line" >> "$temp_file"
            # Add all features from YAML
            for key in "${feature_keys[@]}"; do
                value=$(yq -r ".features.$key" "$config_file" 2>/dev/null)
                echo "$key = $value" >> "$temp_file"
                ui_success_simple "Set feature: $key = $value" 0
            done
            continue
        fi

        # Check if we're leaving features section (entering new section)
        if [[ "$line" =~ ^\[.*\] && $in_features_section -eq 1 ]]; then
            in_features_section=0
        fi

        # Skip lines that are in the features section (we already added new ones)
        if [[ $in_features_section -eq 1 ]]; then
            continue
        fi

        echo "$line" >> "$temp_file"
    done < "$CODEX_CONFIG_FILE"

    # If no features section was found, add it at the beginning
    if [[ $features_section_found -eq 0 ]]; then
        echo "[features]" > "$temp_file.new"
        for key in "${feature_keys[@]}"; do
            value=$(yq -r ".features.$key" "$config_file" 2>/dev/null)
            echo "$key = $value" >> "$temp_file.new"
            ui_success_simple "Set feature: $key = $value" 0
        done
        echo "" >> "$temp_file.new"
        # Append the rest of the original config (if temp file exists)
        if [[ -f "$temp_file" ]]; then
            cat "$temp_file" >> "$temp_file.new"
        fi
        mv "$temp_file.new" "$temp_file"
    fi

    # Replace original with updated config
    if [[ -f "$temp_file" ]]; then
        mv "$temp_file" "$CODEX_CONFIG_FILE"
    fi
}

# Remove deprecated experimental_use_rmcp_client if it exists
if [[ -f "$CODEX_CONFIG_FILE" ]] && grep -q '^experimental_use_rmcp_client' "$CODEX_CONFIG_FILE" 2>/dev/null; then
    # Use a temp file to remove the deprecated setting
    grep -v '^experimental_use_rmcp_client' "$CODEX_CONFIG_FILE" > "${CODEX_CONFIG_FILE}.tmp"
    mv "${CODEX_CONFIG_FILE}.tmp" "$CODEX_CONFIG_FILE"
    ui_info_simple "Removed deprecated experimental_use_rmcp_client setting" 0
fi

# Collect and merge features from both configs
declare -A all_features
if [[ -f "$COMMON_CONFIG" ]]; then
    feature_keys=($(yq -r '.features | keys[]' "$COMMON_CONFIG" 2>/dev/null))
    for key in "${feature_keys[@]}"; do
        value=$(yq -r ".features.$key" "$COMMON_CONFIG" 2>/dev/null)
        all_features[$key]=$value
    done
fi

if [[ -f "$PROFILE_CONFIG" ]]; then
    feature_keys=($(yq -r '.features | keys[]' "$PROFILE_CONFIG" 2>/dev/null))
    for key in "${feature_keys[@]}"; do
        value=$(yq -r ".features.$key" "$PROFILE_CONFIG" 2>/dev/null)
        all_features[$key]=$value  # Profile overrides common
    done
fi

# Configure all features once
if [[ ${#all_features[@]} -gt 0 ]]; then
    temp_file="${CODEX_CONFIG_FILE}.tmp"

    # Remove any existing temp file to ensure clean state
    rm -f "$temp_file"

    in_features_section=0
    features_written=0

    # Start fresh temp file with features section
    echo "[features]" > "$temp_file"
    for key in "${(@k)all_features}"; do
        echo "$key = ${all_features[$key]}" >> "$temp_file"
        ui_success_simple "Set feature: $key = ${all_features[$key]}" 0
    done
    echo "" >> "$temp_file"
    features_written=1

    # If config file exists, preserve non-feature content
    if [[ -f "$CODEX_CONFIG_FILE" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Skip any [features] section headers (we already wrote it above)
            if [[ "$line" =~ ^\\[features\\] ]]; then
                in_features_section=1
                continue
            fi

            # Check if entering a new non-features section
            if [[ "$line" =~ ^\\[.*\\] ]]; then
                # Only exit features section if we're in it
                if [[ $in_features_section -eq 1 ]]; then
                    in_features_section=0
                fi
                # Preserve this new section header
                echo "$line" >> "$temp_file"
                continue
            fi

            # Skip lines in features section
            if [[ $in_features_section -eq 1 ]]; then
                continue
            fi

            # Preserve all other content
            echo "$line" >> "$temp_file"
        done < "$CODEX_CONFIG_FILE"
    fi

    # Ensure temp file was created successfully
    if [[ ! -f "$temp_file" ]]; then
        ui_error_msg "Failed to create temporary config file" 0
        exit 1
    fi

    mv "$temp_file" "$CODEX_CONFIG_FILE"
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

    # Use eval to expand variables (safe because we validate them with check_env_vars first)
    eval echo "$text"
}

# Function to add MCP server
add_codex_mcp_server() {
    local name="$1"
    shift

    # Remaining args could be url, command, or command with args/env
    local -a extra_args=("$@")

    # Check if environment variables in extra args are set
    for arg in "${extra_args[@]}"; do
        if ! check_env_vars "$arg"; then
            ui_warning_simple "Skipping MCP server '$name' due to missing environment variables" 0
            return 1
        fi
    done

    # Check if already configured and remove it to ensure clean state
    if codex mcp list 2>&1 | grep -q "^$name\$"; then
        ui_info_simple "Removing existing MCP server '$name' for clean re-add" 0
        codex mcp remove "$name" >/dev/null 2>&1
    fi

    # Separate command args from env vars
    local -a cmd_parts=()
    local -a env_vars=()

    for arg in "${extra_args[@]}"; do
        if [[ "$arg" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
            # This is an environment variable (KEY=VALUE)
            env_vars+=("$arg")
        else
            # This is a command or argument
            cmd_parts+=("$arg")
        fi
    done

    # Build codex mcp add command
    # Syntax: codex mcp add <name> --env KEY=VALUE -- <command>
    local -a cmd=(codex mcp add)

    # Name comes FIRST
    cmd+=("$name")

    # Add environment variables with --env flag
    for env_var in "${env_vars[@]}"; do
        cmd+=(--env "$env_var")
    done

    # Add command parts (or URL)
    if [[ ${#cmd_parts[@]} -gt 0 ]]; then
        # If first part looks like a URL and is the only part, use --url
        if [[ ${#cmd_parts[@]} -eq 1 && "${cmd_parts[1]}" =~ ^https?:// ]]; then
            cmd+=(--url "${cmd_parts[1]}")
        else
            # Command-based server - always add -- separator before command
            cmd+=(--)
            cmd+=("${cmd_parts[@]}")
        fi
    fi

    # Add the server
    ui_debug_command "${cmd[@]}"
    local output
    output=$("${cmd[@]}" 2>&1)
    if [[ $? -eq 0 ]]; then
        ui_success_simple "Added MCP server: $name" 0
        return 0
    else
        ui_error_msg "Failed to add MCP server: $name" 0
        if [[ -n "$output" ]]; then
            ui_error_msg "  Codex CLI: $output" 0
        fi
        return 1
    fi
}

# Process common MCP servers (if config exists)
if [[ -f "$COMMON_CONFIG" ]]; then
    # Read common MCP servers from YAML
    mcp_names=($(yq -r '.mcp_servers | keys[]' "$COMMON_CONFIG" 2>/dev/null))

    for name in "${mcp_names[@]}"; do
        # Check if it's a URL-only config
        url=$(yq -r ".mcp_servers.$name.url" "$COMMON_CONFIG" 2>/dev/null)

        if [[ -n "$url" && "$url" != "null" ]]; then
            # URL-only MCP server
            url=$(expand_env_vars "$url")
            add_codex_mcp_server "$name" "$url"
        else
            # Command-based MCP server
            command=$(yq -r ".mcp_servers.$name.command" "$COMMON_CONFIG" 2>/dev/null)
            if [[ -z "$command" || "$command" == "null" ]]; then
                ui_warning_simple "MCP server '$name' has no url or command" 0
                continue
            fi

            command=$(expand_env_vars "$command")

            # Read args - use while loop to preserve quoted strings
            local -a args=()
            while IFS= read -r arg; do
                [[ -n "$arg" ]] && args+=("$(expand_env_vars "$arg")")
            done < <(yq -r ".mcp_servers.$name.args[]" "$COMMON_CONFIG" 2>/dev/null)

            # Read environment variables if they exist
            local -a env_vars=()
            local env_keys=($(yq -r ".mcp_servers.$name.env | keys[]" "$COMMON_CONFIG" 2>/dev/null))
            local env_validation_failed=0

            for key in "${env_keys[@]}"; do
                value=$(yq -r ".mcp_servers.$name.env.$key" "$COMMON_CONFIG" 2>/dev/null)

                # Validate environment variables before expanding
                if ! check_env_vars "$value"; then
                    ui_warning_simple "Skipping MCP server '$name' due to missing environment variables" 0
                    env_validation_failed=1
                    break
                fi

                value=$(expand_env_vars "$value")
                env_vars+=("$key=$value")
            done

            if [[ $env_validation_failed -eq 0 ]]; then
                add_codex_mcp_server "$name" "$command" "${args[@]}" "${env_vars[@]}"
            fi
        fi
    done
fi

# Process profile-specific MCP servers (if config exists)
if [[ -f "$PROFILE_CONFIG" ]]; then
    # Read profile-specific MCP servers from YAML
    mcp_names=($(yq -r '.mcp_servers | keys[]' "$PROFILE_CONFIG" 2>/dev/null))

    for name in "${mcp_names[@]}"; do
        # Check if it's a URL-only config
        url=$(yq -r ".mcp_servers.$name.url" "$PROFILE_CONFIG" 2>/dev/null)

        if [[ -n "$url" && "$url" != "null" ]]; then
            # URL-only MCP server
            url=$(expand_env_vars "$url")
            add_codex_mcp_server "$name" "$url"
        else
            # Command-based MCP server
            command=$(yq -r ".mcp_servers.$name.command" "$PROFILE_CONFIG" 2>/dev/null)
            if [[ -z "$command" || "$command" == "null" ]]; then
                ui_warning_simple "MCP server '$name' has no url or command" 0
                continue
            fi

            command=$(expand_env_vars "$command")

            # Read args - use while loop to preserve quoted strings
            local -a args=()
            while IFS= read -r arg; do
                [[ -n "$arg" ]] && args+=("$(expand_env_vars "$arg")")
            done < <(yq -r ".mcp_servers.$name.args[]" "$PROFILE_CONFIG" 2>/dev/null)

            # Read environment variables if they exist
            local -a env_vars=()
            local env_keys=($(yq -r ".mcp_servers.$name.env | keys[]" "$PROFILE_CONFIG" 2>/dev/null))
            local env_validation_failed=0

            for key in "${env_keys[@]}"; do
                value=$(yq -r ".mcp_servers.$name.env.$key" "$PROFILE_CONFIG" 2>/dev/null)

                # Validate environment variables before expanding
                if ! check_env_vars "$value"; then
                    ui_warning_simple "Skipping MCP server '$name' due to missing environment variables" 0
                    env_validation_failed=1
                    break
                fi

                value=$(expand_env_vars "$value")
                env_vars+=("$key=$value")
            done

            if [[ $env_validation_failed -eq 0 ]]; then
                add_codex_mcp_server "$name" "$command" "${args[@]}" "${env_vars[@]}"
            fi
        fi
    done
fi

echo ""
ui_success_simple "Codex CLI configuration complete" 0
ui_info_simple "Config file: $HOME/.codex/config.toml" 0

ui_spacer
