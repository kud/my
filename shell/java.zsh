################################################################################
#                                                                              #
#   ☕ JAVA ENVIRONMENT INITIALIZATION                                          #
#   -------------------------------                                            #
#   Sets up Java via mise (SDKMAN removed).                                    #
#                                                                              #
################################################################################

# Java via mise; derive JAVA_HOME dynamically each interactive shell
if command -v mise >/dev/null 2>&1; then
  if JAVA_PATH=$(mise which java 2>/dev/null); then
    export JAVA_HOME="$(dirname "$(dirname "$JAVA_PATH")")"
  fi
elif command -v java >/dev/null 2>&1; then
  JAVA_BIN=$(command -v java)
  export JAVA_HOME="$(dirname "$(dirname "$JAVA_BIN")")"
fi
