# ################################################################################
#                                                                                #
#   🖲️  CURSOR CONFIGURATION                                                     #
#   ---------------------                                                        #
#   Sets terminal cursor style and behavior for improved visual experience.     #
#                                                                                #
# ################################################################################

echo -ne '\e[5 q'

# Restore a hidden cursor on prompt redraw; some TUIs forget to reset it.
if [[ -z ${__MY_CURSOR_RESTORE_HOOK:-} ]]; then
  __MY_CURSOR_RESTORE_HOOK=1

  autoload -Uz add-zsh-hook

  typeset -ga __MY_CURSOR_RESTORE_CMD
  if command -v tput >/dev/null 2>&1; then
    __MY_CURSOR_RESTORE_CMD=(tput cnorm)
  else
    __MY_CURSOR_RESTORE_CMD=(printf '\e[?25h')
  fi

  function __my_ensure_cursor_visible() {
    "${__MY_CURSOR_RESTORE_CMD[@]}" 2>/dev/null || true
  }

  add-zsh-hook precmd __my_ensure_cursor_visible
fi
