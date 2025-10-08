################################################################################
#                                                                              #
#   🧰 MISE RUNTIME MANAGER INITIALISATION                                      #
#   -------------------------------------                                       #
#   Centralised activation for all toolchain runtimes managed by mise.         #
#   This replaces per-language activation blocks in node/python/ruby scripts.  #
#                                                                              #
################################################################################

# Activate mise only once per interactive shell to provide shims for
# configured runtimes (node, python, ruby, etc.). Guard with interactivity
# to avoid overhead in non-interactive subshells (e.g. CI hooks, scripts).
if [[ $- == *i* ]] && command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi
