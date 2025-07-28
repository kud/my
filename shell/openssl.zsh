# ################################################################################
#                                                                                #
#   🔒 OPENSSL ENVIRONMENT                                                        #
#   ---------------------                                                        #
#   OpenSSL library and include paths.                                           #
#                                                                                #
# ################################################################################

export LDFLAGS="-L${HOMEBREW_PREFIX}/opt/openssl/lib"
export CPPFLAGS="-I${HOMEBREW_PREFIX}/opt/openssl/include"
export SSL_CERT_FILE=${HOMEBREW_PREFIX}/etc/openssl@3/cert.pem
