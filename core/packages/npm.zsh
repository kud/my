#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   📦 NODE.JS PACKAGE MANAGER                                                 #
#   -------------------------                                                  #
#   Manages global npm packages for development tools and CLI utilities.      #
#   Installs essential Node.js tools for modern web development workflow.     #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

echo_task_start "Setting up global Node.js packages"

# Check if Node.js and npm are available
if ! command -v npm >/dev/null 2>&1; then
    echo_fail "npm not found. Please install Node.js first."
    return 1
fi

################################################################################
# 🔄 NPM SYSTEM UPDATE
################################################################################

echo_info "Updating existing global npm packages"
npm update -g --quiet

echo_space
echo_success "Global npm packages updated successfully"

################################################################################
# 🛠️ DEVELOPMENT TOOLS & UTILITIES
################################################################################

echo_info "Installing essential development and utility packages"

npminstall aicommits # Automated AI commit messages for git - https://github.com/Nutlope/aicommits
npminstall @anthropic-ai/claude-code # AI-powered coding assistant - https://github.com/anthropics/claude-code
npminstall battery-level-cli # Get battery level from the command line - https://github.com/sindresorhus/battery-level-cli
npminstall bodybuilder # ElasticSearch query body builder - https://github.com/danpaz/bodybuilder
npminstall caniuse-cmd # Can I use... from the command line - https://github.com/sgentle/caniuse-cmd
npminstall diff-so-fancy # Good-lookin' diffs for git - https://github.com/so-fancy/diff-so-fancy
npminstall envinfo # Print environment info for debugging - https://github.com/tabrindle/envinfo
npminstall eslint # Pluggable JavaScript linter - https://eslint.org/
npminstall fast-cli # Test your download/upload speed from the command line - https://github.com/sindresorhus/fast-cli
npminstall figlet-cli # Create ASCII art from text - https://github.com/patorjk/figlet-cli
npminstall fixme # Find and list FIXME/TODO comments in code - https://www.npmjs.com/package/fixme
npminstall fkill-cli # Fabulously kill processes - https://github.com/sindresorhus/fkill-cli
npminstall fraktur # Write with great font in terminal - https://www.npmjs.com/package/fraktur
npminstall fx # Command-line JSON processing tool - https://github.com/antonmedv/fx
npminstall gh-pages # Deploy to GitHub Pages - https://github.com/tschaub/gh-pages
npminstall git-branch-delete # Delete git branches from the CLI - https://github.com/paulirish/git-branch-delete
npminstall git-branch-select # Select git branches interactively - https://github.com/paulirish/git-branch-select
npminstall gnomon # Pretty-print timestamps in logs - https://github.com/chronomaniac/gnomon
npminstall gulp-cli # Command line interface for gulp.js - https://gulpjs.com/
npminstall hicat # Command-line syntax highlighter - https://www.npmjs.com/package/hicat
npminstall how2 # Stack Overflow from the terminal - https://github.com/santinic/how2
npminstall http-server # Simple, zero-config command-line http server - https://github.com/http-party/http-server
npminstall imagemin # Minify images - https://github.com/imagemin/imagemin
npminstall import-cost # Display import size in the terminal - https://github.com/wix/import-cost
npminstall is-up-cli # Check if a website is up - https://github.com/sindresorhus/is-up-cli
npminstall iterm2-tab-set # Set iTerm2 tab color, title, and/or badge - https://github.com/mbadolato/iterm2-tab-set
npminstall jake # JavaScript build tool - https://github.com/jakejs/jake
npminstall jscodeshift # Codemod toolkit for JavaScript - https://github.com/facebook/jscodeshift
npminstall kmdr # Learn CLI commands with kmdr explain - https://kmdr.sh
npminstall lighthouse # Auditing, performance metrics, and best practices for Progressive Web Apps - https://github.com/GoogleChrome/lighthouse
npminstall localtunnel # Expose localhost to the world - https://github.com/localtunnel/localtunnel
npminstall markdown-live # Live preview markdown files - https://www.npmjs.com/package/markdown-live
npminstall nativefier # Make any web page a desktop app - https://github.com/nativefier/nativefier
npminstall nodemon # Monitor for changes and automatically restart node app - https://github.com/remy/nodemon
npminstall np # Better npm publish - https://github.com/sindresorhus/np
npminstall npm-check # Check if npm modules are updated - https://github.com/dylang/npm-check
npminstall npm-check-updates # Find newer versions of dependencies - https://github.com/raineorshine/npm-check-updates
npminstall npm-upgrade # Upgrade npm dependencies interactively - https://github.com/knownasilya/npm-upgrade
npminstall ntl # Npm Task List: Interactive cli menu to list/run npm tasks - https://github.com/ruyadorno/ntl
npminstall open-pip-cli # Open a pip package's PyPI page from the CLI - https://github.com/sindresorhus/open-pip-cli
npminstall opencommit # AI-powered commit message generator - https://github.com/di-sukharev/opencommit
npminstall pageres-cli # Responsive website screenshots - https://github.com/sindresorhus/pageres
npminstall prettier # Opinionated code formatter - https://prettier.io/
npminstall prettier-plugin-ini # Prettier plugin for INI files - https://github.com/ArnaudBarre/prettier-plugin-ini
npminstall react-native-cli # React Native command line tools - https://github.com/react-native-community/cli
npminstall serve # Static file serving and directory listing - https://github.com/vercel/serve
npminstall speed-test # Test internet connection speed - https://github.com/sindresorhus/speed-test
npminstall svgo # SVG Optimizer - https://github.com/svg/svgo
npminstall tldr # Simplified and community-driven man pages - https://github.com/tldr-pages/tldr
npminstall tmi # Too many images: download all images from a page - https://www.npmjs.com/package/tmi
npminstall trash-cli # Move files and folders to the trash - https://github.com/sindresorhus/trash-cli
npminstall tslint # Linter for TypeScript - https://github.com/palantir/tslint
npminstall typescript@next # TypeScript nightly build - https://github.com/microsoft/TypeScript
npminstall uncss # Remove unused CSS from your stylesheets - https://github.com/uncss/uncss
npminstall vercel # Deploy web projects with Vercel - https://vercel.com/docs/cli
npminstall vtop # Graphical activity monitor for the command line - https://github.com/MrRio/vtop
npminstall web-ext # Command line tool for web extension development - https://github.com/mozilla/web-ext
npminstall weinre # Debugger for web pages - http://people.apache.org/~pmuellr/weinre-docs/latest/
npminstall zx # A tool for writing better scripts - https://github.com/google/zx

npminstall @kud/am-i-admin-cli
npminstall @kud/git-cherry-pick-interactive-cli
npminstall @kud/soap-cli
npminstall @kud/wifi-tool-cli

# Execute batch npm installation
npminstall_run

################################################################################
# ⚙️ NPM & YARN CONFIGURATION
################################################################################

echo_space
echo_info "Configuring npm and yarn settings"

# NPM configuration for better package management
npm config set save-exact true                    # Save exact versions
npm config set tag-version-prefix ""              # No prefix for version tags
npm config set progress false                     # Disable progress bar
npm config set fetch-retries 3                    # Retry failed requests
npm config set fetch-retry-mintimeout 15000       # Min timeout for retries
npm config set fetch-retry-maxtimeout 90000       # Max timeout for retries

# Yarn configuration
yarn config set save-exact true                   # Save exact versions in yarn

echo_success "npm and yarn configured successfully"

################################################################################
# 🔧 PROFILE-SPECIFIC EXTENSIONS
################################################################################

# Load profile-specific npm configurations
source $MY/profiles/$OS_PROFILE/core/packages/npm.zsh 2>/dev/null

echo_space
echo_task_done "Node.js package setup completed"
echo_success "Global npm packages and configurations are ready for development! 🚀"
