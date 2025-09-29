################################################################################
#                                                                              #
#   ☕ JAVA ENVIRONMENT INITIALIZATION                                          #
#   -------------------------------                                            #
#   Sets up Java via mise (SDKMAN removed).                                    #
#                                                                              #
################################################################################

# Switched to mise-managed Java (sdkman removed)
# Ensure mise provides java in PATH via shims.
# Optionally set JAVA_HOME from `mise which java` parent.
if command -v java >/dev/null 2>&1; then
  JAVA_BIN=$(command -v java)
  export JAVA_HOME="$(dirname "$(dirname "$JAVA_BIN")")"
fi
