################################################################################
#                                                                              #
#   🏠 LOCAL CONFIGURATION SETUP                                               #
#   ------------------------------                                             #
#   Handles local machine configuration and OS profile setup.                  #
#                                                                              #
################################################################################

# Create local config if it doesn't exist
if [[ ! -f "$HOME/.config/zsh/local.zsh" ]]; then
  mkdir -p "$HOME/.config/zsh"
  echo "# Local machine configuration" > "$HOME/.config/zsh/local.zsh"
  echo "# Add machine-specific settings here" >> "$HOME/.config/zsh/local.zsh"
  echo "" >> "$HOME/.config/zsh/local.zsh"

  # Prompt for OS profile if not set
  if [[ -z "$OS_PROFILE" ]]; then
    echo "Setting up local configuration..."
    while true; do
      read "?Enter the profile of this computer (home/work): " OS_PROFILE
      if [[ "$OS_PROFILE" == "home" || "$OS_PROFILE" == "work" ]]; then
        echo "export OS_PROFILE=$OS_PROFILE" >> "$HOME/.config/zsh/local.zsh"
        break
      else
        echo "Invalid input, please enter either 'home' or 'work'"
      fi
    done
  fi
fi

# Include local configuration
[[ -f $HOME/.config/zsh/local.zsh ]] && source $HOME/.config/zsh/local.zsh
