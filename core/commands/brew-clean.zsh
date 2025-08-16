#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🧹 HOMEBREW CASK CLEANUP MANAGER                                           #
#   --------------------------------                                           #
#   Analyzes and cleans up Homebrew casks by comparing installed packages     #
#   with configuration files. Handles missing and orphaned casks.             #
#                                                                              #
################################################################################

# Source required utilities
source $MY/core/utils/ui-kit.zsh
source $MY/core/utils/package-manager-utils.zsh

# Constants and Variables
LOG_FILE="$MY/logs/cleanup.log"
DRY_RUN=false  # Set to true for a dry-run mode
yaml_files=("$(get_main_config_path brew)" "$(get_profile_config_path brew)")
declare -A _BREW__BREW_file_casks_map
declare -A _BREW__BREW_installed_casks_map

# Welcome message
ui_spacer
ui_panel "Homebrew Cask Audit" "Analyzing installed casks vs configuration" "info"
ui_spacer

# Functions
log_action() {
    local log_dir=$(dirname "$LOG_FILE")
    if [[ ! -d "$log_dir" ]]; then
        mkdir -p "$log_dir"
    fi

    echo "$(date): $1" >>"$LOG_FILE"
}

check_dependencies() {
    ui_info_msg "Checking dependencies..."
    ensure_command_available "brew" "Install from https://brew.sh"
    ensure_command_available "yq" "Install with: brew install yq"
    ui_success_simple "All dependencies available"
    ui_spacer
}

check_variables() {
    if [[ -z "$MY" || -z "$OS_PROFILE" ]]; then
        ui_error_msg "Environment variables 'MY' or 'OS_PROFILE' not set"
        ui_muted "  Please configure your environment first"
        exit 1
    fi
}

load_casks_from_files() {
    ui_info_msg "Loading cask configurations..."
    ui_spacer
    
    for yaml_file in "${yaml_files[@]}"; do
        if [[ -f "$yaml_file" ]]; then
            ui_muted "  Reading: $yaml_file"
            # Extract casks from packages.casks array in main config or casks array in profile config
            local casks=$(yq eval '.packages.casks[]?, .casks[]?' "$yaml_file" 2>/dev/null)
            if [[ -n "$casks" ]]; then
                while IFS= read -r cask_name; do
                    if [[ -n "$cask_name" && "$cask_name" != "null" ]]; then
                        _BREW_file_casks_map[$cask_name]=1
                    fi
                done <<< "$casks"
            fi
        else
            ui_warning_simple "Config file missing: $yaml_file"
        fi
    done
    
    ui_success_simple "Loaded ${#_BREW_file_casks_map[@]} casks from configuration"
    ui_spacer
}

check_installed_casks() {
    ui_info_msg "Scanning installed Homebrew casks..."
    installed_casks=$(brew list --cask)
    for cask in ${(f)installed_casks}; do
        _BREW_installed_casks_map[$cask]=1
    done
    ui_success_simple "Found ${#_BREW_installed_casks_map[@]} installed casks"
    ui_spacer
}

compare_casks() {
    local missing_casks=()
    for cask in ${(k)_BREW_file_casks_map}; do
        if [[ -z "${_BREW_installed_casks_map[$cask]}" ]]; then
            missing_casks+=($cask)
        fi
    done

    if [[ ${#missing_casks[@]} -gt 0 ]]; then
        ui_divider "─" 60 "$UI_WARNING"
        ui_warning_msg "Missing Casks Detected"
        ui_divider "─" 60 "$UI_WARNING"
        ui_spacer
        
        ui_muted "  The following casks are in configuration but not installed:"
        ui_spacer
        for cask in "${missing_casks[@]}"; do
            printf "  ${UI_WARNING}⚠${UI_RESET}  %s\n" "$cask"
        done
        ui_spacer
        
        ui_info_simple "Resolution options:"
        ui_muted "  [1] Install missing casks"
        ui_muted "  [2] Ignore for now"
        ui_muted "  [3] Remove from configuration"
        ui_spacer

        while true; do
            ui_input "Choose option [1-3]" "2"
            read choice
            case $choice in
                1)
                    ui_spacer
                    ui_info_msg "Installing missing casks..."
                    for cask in "${missing_casks[@]}"; do
                        log_action "INSTALL: $cask"
                        if $DRY_RUN; then
                            ui_muted "  [DRY-RUN] brew install --cask $cask"
                        else
                            ui_info_simple "Installing $cask..."
                            brew install --cask "$cask" 2>&1 | while IFS= read -r line; do
                                ui_muted "    $line"
                            done
                            ui_success_simple "$cask installed"
                        fi
                    done
                    break
                    ;;
                2)
                    log_action "IGNORE: Missing casks: ${missing_casks[*]}"
                    ui_info_simple "Missing casks ignored"
                    break
                    ;;
                3)
                    ui_spacer
                    ui_info_msg "Removing casks from configuration..."
                    for cask in "${missing_casks[@]}"; do
                        for yaml_file in "${yaml_files[@]}"; do
                            if [[ -f "$yaml_file" ]]; then
                                if yq eval ".packages.casks | contains([\"$cask\"]) // (.casks | contains([\"$cask\"]) // false)" "$yaml_file" 2>/dev/null | grep -q "true"; then
                                    yq eval "del(.packages.casks[] | select(. == \"$cask\")) | del(.casks[] | select(. == \"$cask\"))" -i "$yaml_file"
                                    log_action "REMOVE: $cask from $yaml_file"
                                    ui_success_simple "$cask removed from config"
                                fi
                            fi
                        done
                    done
                    break
                    ;;
                *)
                    ui_error_simple "Invalid choice. Please enter 1, 2, or 3."
                    ;;
            esac
        done
    else
        ui_success_msg "All configured casks are installed ✓"
    fi
    ui_spacer
}

handle_discrepancies() {
    ui_divider "─" 60 "$UI_PRIMARY"
    ui_primary "🔍 Orphaned Cask Analysis"
    ui_divider "─" 60 "$UI_PRIMARY"
    ui_spacer
    
    local orphaned_casks=()
    local casks_to_keep=()
    
    for cask in ${(k)_BREW_installed_casks_map}; do
        if [[ -z "${_BREW_file_casks_map[$cask]}" ]]; then
            orphaned_casks+=($cask)
        fi
    done
    
    if [[ ${#orphaned_casks[@]} -gt 0 ]]; then
        ui_info_msg "Found ${#orphaned_casks[@]} orphaned casks"
        ui_muted "  These casks are installed but not in configuration"
        ui_spacer
        
        for cask in "${orphaned_casks[@]}"; do
            ui_box "Cask: $cask" "Orphaned Package" 60
            ui_spacer
            
            ui_info_simple "Choose action:"
            ui_muted "  [1] Clean with soap (safe uninstall)"
            ui_muted "  [2] Force uninstall"
            ui_muted "  [3] Keep installed"
            ui_spacer

            while true; do
                ui_input "Choice [1-3]" "3"
                read choice
                case $choice in
                    1)
                        log_action "SOAP: $cask"
                        if $DRY_RUN; then
                            ui_muted "  [DRY-RUN] soap $cask"
                        else
                            ui_info_msg "Cleaning $cask with soap..."
                            soap "$cask" 2>&1 | while IFS= read -r line; do
                                ui_muted "  $line"
                            done
                            ui_success_simple "$cask cleaned"
                        fi
                        break
                        ;;
                    2)
                        log_action "UNINSTALL: $cask"
                        if $DRY_RUN; then
                            ui_muted "  [DRY-RUN] brew uninstall $cask"
                        else
                            ui_warning_msg "Uninstalling $cask..."
                            brew uninstall "$cask" 2>&1 | while IFS= read -r line; do
                                ui_muted "  $line"
                            done
                            ui_success_simple "$cask uninstalled"
                        fi
                        break
                        ;;
                    3)
                        log_action "KEEP: $cask"
                        casks_to_keep+=($cask)
                        ui_info_simple "Keeping $cask"
                        break
                        ;;
                    *)
                        ui_error_simple "Invalid choice. Please enter 1, 2, or 3."
                        ;;
                esac
            done
            ui_spacer
        done

        if [[ ${#casks_to_keep[@]} -gt 0 ]]; then
            ui_spacer
            ui_info_msg "Kept casks (consider adding to configuration):"
            for cask in "${casks_to_keep[@]}"; do
                printf "  ${UI_INFO}→${UI_RESET} %s\n" "$cask"
            done
            ui_muted "  Tip: Add these to your brew.yml configuration"
        fi
    else
        ui_success_msg "No orphaned casks found ✓"
    fi
    ui_spacer
}

# Main Script
main() {
    check_dependencies
    check_variables
    
    load_casks_from_files
    check_installed_casks
    compare_casks
    handle_discrepancies
    
    # Final summary
    ui_divider "═" 60 "$UI_SUCCESS"
    ui_spacer
    ui_badge "success" " AUDIT COMPLETE "
    ui_spacer
    
    if [[ -f "$LOG_FILE" ]]; then
        ui_info_simple "Actions logged to: $LOG_FILE"
    fi
    
    ui_success_msg "Homebrew cask audit finished successfully!"
    ui_spacer
}

# Execute main function
main