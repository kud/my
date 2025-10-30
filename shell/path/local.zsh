################################################################################
#                                                                              #
#   🏠 LOCAL USER BIN PATH                                                     #
#   -----------------------                                                    #
#   Adds ~/.local/bin (uv, pipx, rust cargo installs, etc.) if present and     #
#   not already on PATH. Kept separate from project-specific `my` paths.       #
#                                                                              #
################################################################################

if [ -d "$HOME/.local/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;; # already present
    *) export PATH="$HOME/.local/bin:$PATH" ;;
  esac
fi
