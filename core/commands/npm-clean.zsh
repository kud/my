#! /usr/bin/env zsh

# Source UI Kit for beautiful output
source $MY/core/utils/ui-kit.zsh
source $MY/core/utils/helper.zsh

# Welcome message
ui_spacer
ui_panel "NPM Package Audit" "Analyzing global npm packages vs configuration" "info"
ui_spacer

file_paths=("$MY/core/packages/npm")

declare -A file_packages_map
for file_path in "${file_paths[@]}"; do
    while read -r line || [[ -n "$line" ]]; do
        # Remove any content after the # symbol
        line_without_comment=${line%%#*}

        # Trim any leading/trailing spaces
        trimmed_line=$(echo "$line_without_comment" | xargs)

        if [[ "$trimmed_line" =~ ^npm_install\ (@?[a-zA-Z0-9_\-]+(/[a-zA-Z0-9_\-]+)?) ]]; then
            package_name=${match[1]}
            file_packages_map[$package_name]=1
        fi
    done <"$file_path"
done

# Capture the list of globally installed npm packages
ui_info_msg "Scanning globally installed packages..."
installed_packages_json=$(npm list -g --depth=0 --json)
installed_packages=($(echo "$installed_packages_json" | jq -r '.dependencies | keys[]'))
ui_success_simple "Found ${#installed_packages[@]} global packages"
ui_spacer

declare -A installed_packages_map
for package in "${installed_packages[@]}"; do
    installed_packages_map[$package]=1
done

# Check for packages in npm files but not installed
missing_packages=()
for package in ${(k)file_packages_map}; do
    if [[ -z "${installed_packages_map[$package]}" ]]; then
        missing_packages+=($package)
    fi
done

if [[ ${#missing_packages[@]} -gt 0 ]]; then
    ui_warning_msg "Missing packages detected"
    ui_muted "  The following packages are defined but not installed:"
    ui_spacer
    for package in "${missing_packages[@]}"; do
        printf "  ${UI_WARNING}⚠${UI_RESET}  %s\n" "$package"
    done
    ui_spacer
    ui_info_simple "Run 'npm install -g' to install missing packages"
    exit 1
fi

# Check for packages installed but not in npm files and act upon them
packages_to_keep=()
packages_removed=()

ui_divider "─" 60 "$UI_PRIMARY"
ui_primary "🔍 Package Review"
ui_divider "─" 60 "$UI_PRIMARY"
ui_spacer

for package in ${(k)installed_packages_map}; do
    # Ignore system packages
    if [[ "$package" == "npm" || "$package" == "corepack" ]]; then
        continue
    fi

    if [[ -z "${file_packages_map[$package]}" ]]; then
        ui_box "Package: $package" "Orphaned Package" 60
        ui_warning_simple "Not defined in configuration files"
        ui_spacer
        
        ui_info_simple "Choose an action:"
        ui_muted "  [1] Remove package (npm uninstall -g)"
        ui_muted "  [2] Keep package (add to exceptions)"
        ui_spacer
        
        ui_input "Your choice [1/2]" "2"
        read -k choice
        echo
        
        case $choice in
            1)
                ui_info_msg "Removing $package..."
                npm uninstall -g "$package" 2>&1 | while IFS= read -r line; do
                    ui_muted "  $line"
                done
                ui_success_simple "Package removed"
                packages_removed+=("$package")
                ;;
            2)
                ui_info_simple "Package kept"
                packages_to_keep+=("$package")
                ;;
            *)
                ui_warning_simple "Invalid choice - keeping package"
                packages_to_keep+=("$package")
                ;;
        esac
        ui_spacer
    fi
done

# Final summary
ui_divider "═" 60 "$UI_SUCCESS"
ui_spacer

ui_badge "info" " AUDIT COMPLETE "
ui_spacer

if [[ ${#packages_removed[@]} -gt 0 ]]; then
    ui_success_msg "Removed packages:"
    for package in "${packages_removed[@]}"; do
        printf "  ${UI_SUCCESS}✓${UI_RESET} %s\n" "$package"
    done
    ui_spacer
fi

if [[ ${#packages_to_keep[@]} -gt 0 ]]; then
    ui_info_msg "Kept packages (consider adding to config):"
    for package in "${packages_to_keep[@]}"; do
        printf "  ${UI_INFO}→${UI_RESET} %s\n" "$package"
    done
    ui_spacer
    ui_muted "  Tip: Add these to $MY/core/packages/npm.yml to track them"
else
    ui_success_msg "All packages are properly tracked!"
fi

ui_spacer