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

    config_file="$HOME/.config/basic-memory/config.toml"

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

# Check if Basic Memory is installed
if [[ ! -x "$BASIC_MEMORY_CMD" ]]; then
    ui_error_msg "Basic Memory CLI not found at $BASIC_MEMORY_CMD" 1
    ui_error_msg "Install via: uv tool install basic-memory" 1
    return 1
fi

# Check if yq is available
if ! command -v yq >/dev/null 2>&1; then
    ui_error_msg "yq not found. Install with: brew install yq" 1
    return 1
fi

# Get current profile
PROFILE="${OS_PROFILE:-default}"

# Define config file paths
COMMON_CONFIG="$MY/config/cli/basic-memory.yml"
PROFILE_CONFIG="$MY/profiles/$PROFILE/config/cli/basic-memory.yml"

# Function to expand environment variables in a string
expand_env_vars() {
    local text="$1"
    eval echo "$text"
}

# Function to check if a project exists
project_exists() {
    local name="$1"
    local output
    
    # Use timeout to prevent hanging
    output=$(timeout 10 "$BASIC_MEMORY_CMD" status --project "$name" 2>&1)
    local exit_code=$?
    
    # If exit code is 0 or 124 (timeout), project exists
    # Exit code 1 means project doesn't exist or other error
    if [[ $exit_code -eq 0 || $exit_code -eq 124 ]]; then
        return 0
    else
        # Check if the error is about project not existing
        if [[ "$output" =~ "does not exist" ]]; then
            return 1
        fi
        # For other errors, assume project exists to be safe
        return 0
    fi
}

# Function to get current path of a project
get_project_path() {
    local name="$1"
    
    # Try to get path from project info with timeout
    local output
    output=$(timeout 10 "$BASIC_MEMORY_CMD" project info "$name" 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        # Extract path from info output
        # Look for line containing "Path:"
        while IFS= read -r line; do
            if [[ "$line" =~ "Path:" ]]; then
                # Extract path after "Path:"
                local path="${line#*Path:}"
                path="${path## }"  # Trim leading spaces
                path="${path%% }"  # Trim trailing spaces
                echo "$path"
                return 0
            fi
        done <<< "$output"
    fi
    
    return 1
}

# Function to check if a project is default
is_project_default() {
    local name="$1"
    local output
    
    # Use timeout to prevent hanging
    output=$(timeout 10 "$BASIC_MEMORY_CMD" project info "$name" 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        # Look for "Default Project:" line
        while IFS= read -r line; do
            if [[ "$line" =~ "Default Project:" ]]; then
                local default_project="${line#*Default Project:}"
                default_project="${default_project## }"  # Trim leading spaces
                default_project="${default_project%% }"  # Trim trailing spaces
                
                if [[ "$default_project" == "$name" ]]; then
                    return 0
                fi
            fi
        done <<< "$output"
    fi
    
    return 1
}

# Function to add a project
add_project() {
    local name="$1"
    local path="$2"
    local is_default="$3"

    # Expand environment variables in path
    path=$(expand_env_vars "$path")

    # Check if project already exists
    if project_exists "$name"; then
        # Project exists - get current path
        local current_path
        current_path=$(get_project_path "$name")
        
        if [[ -n "$current_path" ]]; then
            # Expand ~ in current_path for comparison
            current_path="${current_path/#\~/$HOME}"

            if [[ "$current_path" == "$path" ]]; then
                ui_info_simple "Project '$name' already at correct path" 0
            else
                ui_info_simple "Project '$name' exists at different path, updating..." 0

                # Move project to new location
                local move_output
                move_output=$("$BASIC_MEMORY_CMD" project move "$name" "$path" 2>&1)
                local move_exit=$?

                if [[ $move_exit -eq 0 ]]; then
                    ui_success_simple "Updated project: $name -> $path" 0
                else
                    ui_error_msg "Failed to move project: $name" 0
                    if [[ -n "$move_output" ]]; then
                        ui_error_msg "  $move_output" 0
                    fi
                    return 1
                fi
            fi
        fi
    else
        # Project doesn't exist, add it
        local output
        output=$("$BASIC_MEMORY_CMD" project add "$name" "$path" 2>&1)
        local exit_code=$?

        if [[ $exit_code -eq 0 ]]; then
            ui_success_simple "Added project: $name -> $path" 0
        else
            ui_error_msg "Failed to add project: $name" 0
            if [[ -n "$output" ]]; then
                ui_error_msg "  $output" 0
            fi
            return 1
        fi
    fi

    # Set as default if needed
    if [[ "$is_default" == "true" ]]; then
        if ! is_project_default "$name"; then
            "$BASIC_MEMORY_CMD" project default "$name" >/dev/null 2>&1
            ui_success_simple "Set '$name' as default project" 0
        fi
    fi
}

# Process common projects (if config exists)
if [[ -f "$COMMON_CONFIG" ]]; then
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
    project_names=($(yq -r '.projects | keys[]' "$PROFILE_CONFIG" 2>/dev/null))

    for name in "${project_names[@]}"; do
        path=$(yq -r ".projects.$name.path" "$PROFILE_CONFIG" 2>/dev/null)
        is_default=$(yq -r ".projects.$name.default // false" "$PROFILE_CONFIG" 2>/dev/null)

        if [[ -n "$path" ]]; then
            add_project "$name" "$path" "$is_default"
        fi
    done
fi

ui_success_simple "Basic Memory configuration complete" 1
