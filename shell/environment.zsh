################################################################################
#                                                                              #
#   ⚡ ENVIRONMENT CONFIGURATION                                               #
#   ----------------------------                                               #
#   Environment configuration and smart URL handling.                        #
#                                                                              #
################################################################################

#
# Smart URLs - Handle URL pasting and quoting
#

autoload -Uz is-at-least
if [[ $ZSH_VERSION != 5.1.1 && $TERM != dumb ]]; then
  if is-at-least 5.2; then
    autoload -Uz bracketed-paste-url-magic
    zle -N bracketed-paste bracketed-paste-url-magic
  elif is-at-least 5.1; then
    autoload -Uz bracketed-paste-magic
    zle -N bracketed-paste bracketed-paste-magic
  fi
  autoload -Uz url-quote-magic
  zle -N self-insert url-quote-magic
fi

#
# General Options
#

setopt COMBINING_CHARS      # Combine zero-length punctuation characters (accents)
setopt INTERACTIVE_COMMENTS # Enable comments in interactive shell
setopt RC_QUOTES            # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'
unsetopt MAIL_WARNING       # Don't print warning if mail file accessed

# Allow mapping Ctrl+S and Ctrl+Q shortcuts
[[ -r ${TTY:-} && -w ${TTY:-} && $+commands[stty] == 1 ]] && stty -ixon <$TTY >$TTY

#
# Job Control
#

setopt LONG_LIST_JOBS       # List jobs in long format by default
setopt AUTO_RESUME          # Attempt to resume existing job before creating new process
setopt NOTIFY               # Report status of background jobs immediately
unsetopt BG_NICE            # Don't run background jobs at lower priority
unsetopt HUP                # Don't kill jobs on shell exit
unsetopt CHECK_JOBS         # Don't report on jobs when shell exits

#
# Termcap - Colorized man pages
#

export LESS_TERMCAP_mb=$'\E[01;31m'       # Begins blinking
export LESS_TERMCAP_md=$'\E[01;31m'       # Begins bold
export LESS_TERMCAP_me=$'\E[0m'           # Ends mode
export LESS_TERMCAP_se=$'\E[0m'           # Ends standout-mode
export LESS_TERMCAP_so=$'\E[00;47;30m'    # Begins standout-mode
export LESS_TERMCAP_ue=$'\E[0m'           # Ends underline
export LESS_TERMCAP_us=$'\E[01;32m'       # Begins underline