#!/usr/bin/env zsh

# Load helper functions
source $MY/core/utils/helper.zsh

# Determine Firefox profile path
PROFILE_DIR="$HOME/Library/Application Support/Firefox/Profiles"
DEFAULT_FOLDER=$(ls "$PROFILE_DIR" | grep .default-nightly)
PREFS_FILE="$PROFILE_DIR/$DEFAULT_FOLDER/prefs.js"
CONTAINERS_FILE="$PROFILE_DIR/$DEFAULT_FOLDER/containers.json"
EXTENSION_SETTINGS_FILE="$PROFILE_DIR/$DEFAULT_FOLDER/extension-settings.json"

# Function to update Firefox preferences
update_pref() {
  local key="$1"
  local value="$2"
  echo "user_pref(\"$key\", $value);" >>"$PREFS_FILE"
}

echo_title_update "Firefox configuration"

# Close Firefox Nightly to safely apply changes
quit "Firefox Nightly"
sleep 5

# ╔═════════════════════════════════════════════╗
# ║                Global Preferences           ║
# ╚═════════════════════════════════════════════╝

# Disable warning on about:config
update_pref "browser.aboutConfig.showWarning" false

# Disable zoom with Cmd + Mousewheel
update_pref "mousewheel.with_meta.action" 0

# Turn off domain guessing
update_pref "browser.fixup.alternate.enabled" false

# Disable warning when closing tabs
update_pref "browser.tabs.warnOnClose" false

# Prevent closing the window when the last tab is closed
update_pref "browser.tabs.closeWindowWithLastTab" false

# Hide "Firefox View" button
update_pref "browser.tabs.firefox-view" false

# Show tabs in titlebar
update_pref "browser.tabs.inTitlebar" 1

# Disable web search in the address bar
update_pref "keyword.enabled" false

# Hide specific search engines
update_pref "browser.search.hiddenOneOffs" '"Google,Bing,Amazon.co.uk,Chambers (UK),DuckDuckGo,eBay,Twitter,Wikipedia (en)"'

# Disable search suggestions
update_pref "browser.search.suggest.enabled" false

# Hide search bar on new tab page
update_pref "browser.newtabpage.activity-stream.showSearch" false

# Hide sponsored content on new tab page
update_pref "browser.newtabpage.activity-stream.showSponsored" false
update_pref "browser.newtabpage.activity-stream.showSponsoredTopSites" false

# Hide top stories and top sites on new tab page
update_pref "browser.newtabpage.activity-stream.feeds.section.topstories" false
update_pref "browser.newtabpage.activity-stream.feeds.topsites" false

# Disable new tab page entirely (shows blank)
update_pref "browser.newtabpage.enabled" false

# Set homepage to blank
update_pref "browser.startup.homepage" '"about:blank"'

# Enable punycode to prevent phishing
update_pref "network.IDN_show_punycode" true

# Disable Pocket
update_pref "extensions.pocket.enabled" false

# Enable auto-hide in fullscreen mode
update_pref "browser.fullscreen.autohide" true

# Disable Safari-like modal highlights for Find
update_pref "findbar.modalHighlight" false

# Disable the megabar for URL search
update_pref "browser.urlbar.megabar" false

# Disable Quick Suggest (sponsored and non-sponsored)
update_pref "browser.urlbar.suggest.quicksuggest.nonsponsored" false
update_pref "browser.urlbar.suggest.quicksuggest.sponsored" false

# Enable query stripping for privacy
update_pref "privacy.query_stripping.enabled" true

# Disable auto-scroll on middle click
update_pref "general.autoScroll" false

# Enable Picture-in-Picture (PiP) when switching tabs
update_pref "media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled" true

# Enable AI chat feature
update_pref "browser.ml.chat.enabled" true

# Set the AI chat provider
update_pref "browser.ml.chat.provider" '"https://chatgpt.com"'

# Enable sidebar revamp
update_pref "sidebar.revamp" true

# Enable vertical tabs in the sidebar
update_pref "sidebar.verticalTabs" true

# Enable userChrome.css
update_pref "toolkit.legacyUserProfileCustomizations.stylesheets" true

# Hide bookmarks bar (set to "never", or use "always" if you want it visible)
update_pref "browser.toolbars.bookmarks.visibility" '"never"'

# Hide mobile bookmarks in bookmarks menu
update_pref "browser.bookmarks.showMobileBookmarks" false

# Set spellcheck language (0 = off, 1 = multi-lingual, 2 = single)
update_pref "layout.spellcheckDefault" 0

# ╔═════════════════════════════════════════════╗
# ║                Sync Preferences             ║
# ╚═════════════════════════════════════════════╝

# Ignore addon enable/disable during sync
update_pref "services.sync.prefs.sync.addons.ignoreUserEnabledChanges" true
update_pref "services.sync.addons.ignoreUserEnabledChanges" true

# Decline syncing form data and history
update_pref "services.sync.declinedEngines" '"forms,history"'

# ╔═════════════════════════════════════════════╗
# ║             Developer Tools Settings        ║
# ╚═════════════════════════════════════════════╝

# Enable browser chrome debugging
update_pref "devtools.chrome.enabled" true

# Enable eyedropper tool
update_pref "devtools.command-button-eyedropper.enabled" true

# Enable paint flashing tool
update_pref "devtools.command-button-paintflashing.enabled" true

# Disable responsive design mode
update_pref "devtools.command-button-responsive.enabled" false

# Enable Scratchpad tool
update_pref "devtools.command-button-scratchpad.enabled" true

# Enable screenshot tool
update_pref "devtools.command-button-screenshot.enabled" true

# Disable split console
update_pref "devtools.command-button-splitconsole.enabled" false

# Enable remote debugging
update_pref "devtools.debugger.remote-enabled" true

# Enable DOM inspection
update_pref "devtools.dom.enabled" true

# Set editor keymap to Sublime Text
update_pref "devtools.editor.keymap" '"sublime"'

# Log telemetry onboarding
update_pref "devtools.onboarding.telemetry.logged" true

# Enable new performance panel
update_pref "devtools.performance.new-panel-enabled" true

# Enable Scratchpad tool
update_pref "devtools.scratchpad.enabled" true

# Disable audio in screenshots
update_pref "devtools.screenshot.audio.enabled" false

# Set DevTools to open in a side pane
update_pref "devtools.toolbox.host" '"right"'

# Enable timestamps in console messages
update_pref "devtools.webconsole.timestampMessages" true

# Enable WebIDE widget
update_pref "devtools.webide.widget.enabled" true

# Disable cache during development
update_pref "devtools.cache.disabled" true

# Enable local tab debugging
update_pref "devtools.aboutdebugging.local-tab-debugging" true

source $MY/profiles/$OS_PROFILE/core/apps/firefox.zsh 2>/dev/null

echo_success "Settings have been applied"

# ╔═════════════════════════════════════════════╗
# ║          Manage userChrome.css File         ║
# ╚═════════════════════════════════════════════╝

USER_CHROME_DIR="$PROFILE_DIR/$DEFAULT_FOLDER/chrome"
USER_CHROME_FILE="$USER_CHROME_DIR/userChrome.css"

if [[ ! -d "$USER_CHROME_DIR" ]]; then
  mkdir -p "$USER_CHROME_DIR"
  echo "Created directory: $USER_CHROME_DIR"
fi

cat <<EOF >"$USER_CHROME_FILE"
/* No scroll on sidebar */
#vertical-pinned-tabs-container {
  max-height: 100% !important;
}

/* Give background to any tab */
#tabbrowser-arrowscrollbox {
  & .tab-background {
  .tabbrowser-tab:not(:hover) > .tab-stack > &:not([selected], [multiselected]) {
      background-color: color-mix(in srgb, currentColor 7%, transparent) !important;
    }
  }
}

/* Move container indicator */
/*
.tabbrowser-tab[usercontextid] > .tab-stack > .tab-background > .tab-context-line {
  #vertical-pinned-tabs-container &, #tabbrowser-tabs[orient="vertical"] & {
    margin: 4px -6px !important;
  }
}
*/

/* Hide close button on tab */
/*
.tab-close-button.close-icon {
  display: none !important;
}
*/

/* Set the right background for private window */
#navigator-toolbox {
  :root[privatebrowsingmode] & {
    background-color: #281f4d !important;
  }
}

#sidebar-main {
  :root[privatebrowsingmode] & {
    background-color: #281f4d !important;
  }
}

/* Fix container line with Adaptive Tab Bar Colour addon */
.tabbrowser-tab[usercontextid] > .tab-stack > .tab-background > .tab-context-line {
#vertical-pinned-tabs-container &, #tabbrowser-tabs[orient="vertical"] & {
    margin-left: -2px !important;
    margin-right: -2px !important;
  }
}
EOF

echo_success "Styles have been applied"

# ╔═════════════════════════════════════════════╗
# ║               Containers                    ║
# ╚═════════════════════════════════════════════╝

cat <<EOF >"$CONTAINERS_FILE"
{
  "version": 5,
  "lastUserContextId": 322,
  "identities": [
    {
      "icon": "fingerprint",
      "color": "blue",
      "public": true,
      "userContextId": 1,
      "name": "Personal"
    },
    {
      "icon": "briefcase",
      "color": "red",
      "public": true,
      "userContextId": 2,
      "name": "Work"
    },
    {
      "icon": "chill",
      "color": "yellow",
      "public": true,
      "userContextId": 318,
      "name": "Streaming"
    },
    {
      "icon": "fingerprint",
      "color": "turquoise",
      "public": true,
      "userContextId": 649,
      "name": "Personal at Work"
    },
    {
      "icon": "fence",
      "color": "blue",
      "public": true,
      "userContextId": 322,
      "name": "Facebook"
    }
  ]
}
EOF

echo_success "Containers have been synchronised"


print_firefox_hotkeys_table() {
  cat <<EOT
╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║                                   Firefox Extension Hotkeys Overview                                                  ║
╠═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
║ Extension (Section)                │ Action/Description                                      │ Shortcut               ║
╟────────────────────────────────────┼─────────────────────────────────────────────────────────┼────────────────────────╢
║ Easy Container Shortcuts           │ Open a new tab on the current container                 │ ⌘T                     ║
║                                    │ Open a tab on the first non-default container           │ ⌘1                     ║
║                                    │ Open a tab on the second non-default container          │ ⌘2                     ║
║                                    │ Open a tab on the third non-default container           │ ⌘3                     ║
║                                    │ Open a tab on the fourth non-default container          │ ⌘4                     ║
║                                    │ Open a tab on the fifth non-default container           │ ⌘5                     ║
║                                    │ Open a tab on the sixth non-default container           │ ⌘6                     ║
║                                    │ Open a tab on the seventh non-default container         │ ⌘7                     ║
║                                    │ Open a tab on the eighth non-default container          │ ⌘8                     ║
║                                    │ Open a tab on the ninth non-default container           │ ⌘9                     ║
║                                    │ Reopen the current tab on the default container         │ ⌘0                     ║
║                                    │ Reopen the current tab on the first non-default cont.   │ ⌘⇧1                    ║
║                                    │ Reopen the current tab on the second non-default cont.  │ ⌘⇧2                    ║
║                                    │ Reopen the current tab on the third non-default cont.   │ ⌘⇧3                    ║
║                                    │ Reopen the current tab on the fourth non-default cont.  │ ⌘⇧4                    ║
║                                    │ Reopen the current tab on the fifth non-default cont.   │ ⌘⇧5                    ║
║                                    │ Reopen the current tab on the sixth non-default cont.   │ ⌘⇧6                    ║
║                                    │ Reopen the current tab on the seventh non-default cont. │ ⌘⇧7                    ║
║                                    │ Reopen the current tab on the eighth non-default cont.  │ ⌘⇧8                    ║
║                                    │ Reopen the current tab on the ninth non-default cont.   │ ⌘⇧9                    ║
║                                    │ Open a new window on the current container              │ ⌥T                     ║
║                                    │ Open a window on the first non-default container        │ ⌥1                     ║
║                                    │ Open a window on the second non-default container       │ ⌥2                     ║
║                                    │ Open a window on the third non-default container        │ ⌥3                     ║
║                                    │ Open a window on the fourth non-default container       │ ⌥4                     ║
║                                    │ Open a window on the fifth non-default container        │ ⌥5                     ║
║                                    │ Open a window on the sixth non-default container        │ ⌥6                     ║
║                                    │ Open a window on the seventh non-default container      │ ⌥7                     ║
║                                    │ Open a window on the eighth non-default container       │ ⌥8                     ║
║                                    │ Open a window on the ninth non-default container        │ ⌥9                     ║
║                                    │                                                         │                        ║
║ Firefox Multi-Account Containers   │ Open container panel                                    │ ^Period                ║
║                                    │                                                         │                        ║
║ Email Address Plus                 │ Copy labeled email address                              │ ⇧⌘Y                    ║
║                                    │                                                         │                        ║
║ Move Tab to Next Window            │ Move Tab to Next Window                                 │ ⇧⌥N                    ║
║                                    │                                                         │                        ║
║ Raindrop.io                        │ Bookmark / Save highlights                              │ ⇧⌥S                    ║
║                                    │ Open sidebar                                            │ ⌘Period                ║
║                                    │                                                         │                        ║
║ Readwise Highlighter               │ Activate toolbar button                                 │ ⌥R                     ║
║                                    │                                                         │                        ║
║ KeePassXC-Browser                  │ Fill Username and Password                              │ ⇧^U                    ║
║                                    │ Fill Password Only                                      │ ⇧^I                    ║
║                                    │ Fill TOTP                                               │ ⇧^O                    ║
║                                    │ Show Password Generator                                 │ ⇧^G                    ║
║                                    │ Save Credentials                                        │ ⇧^S                    ║
╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝

See Firefox > Add-ons (about:addons) > Manage Extension Shortcuts for editing.
EOT
}

# Print the hotkeys table before launching Firefox
print_firefox_hotkeys_table

# Open Firefox Nightly
sleep 2
open -a "Firefox Nightly"
