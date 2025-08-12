#! /usr/bin/env zsh

source $MY/core/utils/helper.zsh

echo_title "🔗 Application Shims Generator"
echo_info "Creating shell commands for installed applications..."

# Check if OS_PROFILE is set
if [[ -z "$OS_PROFILE" ]]; then
    echo_error "OS_PROFILE is not set. Please set your profile (home/work) first."
    exit 1
fi

# Generate shims for the current active profile only
shims_dir="$MY/profiles/$OS_PROFILE/bin/shims"

echo_task_start "Generating shims for profile: $OS_PROFILE"

# Create shims directory if it doesn't exist
mkdir -p "$shims_dir"

# Clean existing shims (only if files exist)
if [[ -n "$(ls -A "$shims_dir" 2>/dev/null)" ]]; then
    rm -rf "$shims_dir"/*
fi

app_count=0

for app in /Applications/*.app
do
  finalName=`echo ${${${app// /-}/\/Applications\//}//.app/} | tr '[:upper:]' '[:lower:]'`
  echo "#! /usr/bin/env zsh\nopen -a \"${app}\"" \$@ > "$shims_dir/open-${finalName}"
  app_count=$((app_count + 1))
  echo_subtle "Created: open-${finalName}"
done

# Set executable permissions
chmod +x "$shims_dir"/*

echo_task_done "Generated ${app_count} shims for $OS_PROFILE"

echo_space
echo_success "Application shims generation complete!"
echo_info "Generated ${app_count} shims in $MY/profiles/$OS_PROFILE/bin/shims/"
echo_subtle "Usage: open-<app-name> (e.g., open-spotify, open-discord)"

