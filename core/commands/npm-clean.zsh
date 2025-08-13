#! /usr/bin/env zsh

source $MY/core/utils/helper.zsh

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
installed_packages_json=$(npm list -g --depth=0 --json)
installed_packages=($(echo "$installed_packages_json" | jq -r '.dependencies | keys[]'))

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
    echo_info "Packages in files but not installed:"
    for package in "${missing_packages[@]}"; do
        echo "$package"
    done
    exit 1  # Exit the script with a non-zero status to indicate an error
fi

echo_space
echo_success "All packages in files are installed."
echo_space

# Check for packages installed but not in npm files and act upon them
packages_to_keep=()
for package in ${(k)installed_packages_map}; do
    # Ignore packages
    if [[ "$package" == "npm" || "$package" == "corepack" ]]; then
        continue
    fi

    if [[ -z "${file_packages_map[$package]}" ]]; then
        echo_space
        echo_info "Package '$package' is installed but not in files."
        echo_space
        echo "What would you like to do?"
        echo "1) Use 'npm uninstall -g'"
        echo "2) Keep and list at the end"
        echo_space
        read -k choice
        echo_spacex2

        case $choice in
            1)
                npm uninstall -g "$package"
                ;;
            2)
                packages_to_keep+=($package)
                ;;
            *)
                echo "Invalid choice. Keeping '$package' for now."
                packages_to_keep+=($package)
                ;;
        esac
    fi
done

if [[ ${#packages_to_keep[@]} -gt 0 ]]; then
    echo_space
    echo_info "Packages you chose to keep:"
    for package in "${packages_to_keep[@]}"; do
        echo "$package"
    done
else
    echo_info "No packages kept."
fi
