################################################################################
#                                                                              #
#   🐍 PYTHON ENVIRONMENT INITIALIZATION                                       #
#   ------------------------------------                                       #
#   Sets up pyenv, pyenv-virtualenv, and related Python environment variables.  #
#                                                                              #
################################################################################

# pyenv
if which pyenv > /dev/null; then
  eval "$(pyenv init --path)"
fi
if which pyenv > /dev/null; then
  eval "$(pyenv init -)"
fi
if which pyenv-virtualenv-init > /dev/null; then
  eval "$(pyenv virtualenv-init -)"
fi
