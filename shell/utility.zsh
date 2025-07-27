################################################################################
#                                                                              #
#   🔧 UTILITY FUNCTIONS                                                       #
#   -----------------                                                          #
#   General shell utilities and helper functions.                              #
#                                                                              #
################################################################################

# Load zmv for mass file operations
# Example: zmv '(*).txt' '$1.bak'  # Rename all .txt files to .bak
autoload -Uz zmv
