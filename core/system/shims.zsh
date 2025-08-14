#! /usr/bin/env zsh


# Check if OS_PROFILE is set
if [[ -z "$OS_PROFILE" ]]; then
    exit 1
fi

# Generate shims for the current active profile only
shims_dir="$MY/profiles/$OS_PROFILE/bin/shims"


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
done

# Set executable permissions
chmod +x "$shims_dir"/*


