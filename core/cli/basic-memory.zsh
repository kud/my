#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🧠 BASIC MEMORY CONFIGURATOR                                               #
#   -----------------------------                                              #
#   Configures Basic Memory CLI with projects from config/cli/basic-memory.yml#
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh
source $MY/core/utils/ui-kit.zsh
source $MY/shell/globals.zsh

# Handle show-config subcommand
if [[ "$1" == "show-config" ]]; then
    ui_subtitle "Basic Memory Config:"

    config_file="$HOME/.basic-memory/config.json"

    if [[ -f "$config_file" ]]; then
        ui_info_simple "$config_file" 0
    else
        ui_warning_simple "$config_file (not found)" 0
    fi
    ui_spacer
    return 0
fi

ui_subsection "Configuring Basic Memory"

# Define basic-memory command path
BASIC_MEMORY_CMD="$HOME/.local/bin/basic-memory"

# Get current profile
PROFILE="${OS_PROFILE:-default}"

# Define config file paths
COMMON_CONFIG="$MY/config/cli/basic-memory.yml"
PROFILE_CONFIG="$MY/profiles/$PROFILE/config/cli/basic-memory.yml"
CONFIG_FILE="$HOME/.basic-memory/config.json"
CONFIG_DIR="$HOME/.basic-memory"
SETTINGS_JSON="{}"

# Function to expand environment variables in a string
expand_env_vars() {
    local text="$1"
    eval echo "$text"
}

# Function to record settings from config
record_settings() {
    local config_file="$1"

    if [[ ! -f "$config_file" ]]; then
        return 0
    fi

    local settings
    settings=$(yq -o=json '.settings // {}' "$config_file" 2>/dev/null)

    if [[ -z "$settings" || "$settings" == "null" ]]; then
        return 0
    fi

    SETTINGS_JSON=$(jq -s '.[0] * .[1]' <(printf '%s' "$SETTINGS_JSON") <(printf '%s' "$settings"))
}

# Function to write settings to config.json
apply_settings_to_config() {
    if [[ "$SETTINGS_JSON" == "{}" ]]; then
        return 0
    fi

    /bin/mkdir -p "$CONFIG_DIR"
    if [[ -f "$CONFIG_FILE" ]]; then
        jq --argjson settings "$SETTINGS_JSON" '. * $settings' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp"
        /bin/mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    else
        jq -n --argjson settings "$SETTINGS_JSON" '$settings' > "$CONFIG_FILE"
    fi
    ui_success_simple "Updated config settings" 0
}

# Function to add a project
add_project() {
    local name="$1"
    local path="$2"
    local is_default="$3"

    # Expand environment variables in path
    path=$(expand_env_vars "$path")

    local output
    output=$("$BASIC_MEMORY_CMD" project add "$name" "$path" 2>&1)
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        ui_success_simple "Added project: $name -> $path" 0
    else
        local move_output
        move_output=$("$BASIC_MEMORY_CMD" project move "$name" "$path" 2>&1)
        local move_exit=$?

        if [[ $move_exit -eq 0 ]]; then
            ui_success_simple "Updated project: $name -> $path" 0
        else
            ui_error_msg "Failed to add project: $name" 0
            if [[ -n "$output" ]]; then
                ui_error_msg "  $output" 0
            fi
            if [[ -n "$move_output" ]]; then
                ui_error_msg "  $move_output" 0
            fi
            return 1
        fi
    fi

    # Set as default if needed
    if [[ "$is_default" == "true" ]]; then
        if "$BASIC_MEMORY_CMD" project default "$name" >/dev/null 2>&1; then
            ui_success_simple "Set '$name' as default project" 0
        else
            ui_error_msg "Failed to set default project: $name" 0
            return 1
        fi
    fi
}

# Process common projects (if config exists)
if [[ -f "$COMMON_CONFIG" ]]; then
    record_settings "$COMMON_CONFIG"
    project_names=($(yq -r '.projects | keys[]' "$COMMON_CONFIG" 2>/dev/null))

    for name in "${project_names[@]}"; do
        path=$(yq -r ".projects.$name.path" "$COMMON_CONFIG" 2>/dev/null)
        is_default=$(yq -r ".projects.$name.default // false" "$COMMON_CONFIG" 2>/dev/null)

        if [[ -n "$path" ]]; then
            add_project "$name" "$path" "$is_default"
        fi
    done
fi

# Process profile-specific projects (if config exists)
if [[ -f "$PROFILE_CONFIG" ]]; then
    record_settings "$PROFILE_CONFIG"
    project_names=($(yq -r '.projects | keys[]' "$PROFILE_CONFIG" 2>/dev/null))

    for name in "${project_names[@]}"; do
        path=$(yq -r ".projects.$name.path" "$PROFILE_CONFIG" 2>/dev/null)
        is_default=$(yq -r ".projects.$name.default // false" "$PROFILE_CONFIG" 2>/dev/null)

        if [[ -n "$path" ]]; then
            add_project "$name" "$path" "$is_default"
        fi
    done
fi

apply_settings_to_config

if [[ -f "$CONFIG_FILE" ]]; then
    ui_subtitle "Config:"
    ui_info_simple "$CONFIG_FILE" 0
fi

ui_success_simple "Basic Memory configuration complete" 1
