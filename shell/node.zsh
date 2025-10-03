# ################################################################################
#                                                                                #
#   🟢 NODE.JS ENVIRONMENT INITIALISATION                                        #
#   -------------------------------                                              #
#   Sets up Node.js via mise (unified runtime manager) and configures npm globals.#
#   Enables Corepack so that Yarn/PNPM versions are tool-managed & reproducible.  #
#                                                                                #
# ################################################################################

# Enable Corepack (ships with modern Node). Provides shim wrappers for
# yarn/pnpm/npm to respect package manager version declarations in package.json.
# Safe to run repeatedly; ignore failures for older Node versions.
if command -v node >/dev/null 2>&1; then
  if command -v corepack >/dev/null 2>&1; then
    COREPACK_ENABLED_MARKER="${XDG_CACHE_HOME:-$HOME/.cache}/my/corepack/enabled"
    if [[ ! -f "$COREPACK_ENABLED_MARKER" ]]; then
      mkdir -p "$(dirname "$COREPACK_ENABLED_MARKER")"
      if corepack enable >/dev/null 2>&1; then
        echo 1 > "$COREPACK_ENABLED_MARKER" 2>/dev/null || true
      fi
    fi
  fi
fi

