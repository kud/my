# Post-Installation Configuration Guide

<!-- ## Project Configuration

- Navigate to your project directory and update the GitHub remote URL to use SSH:
  ```bash
  cd MY
  git remote set-url origin git@github.com:kud/my.git
  ``` -->

<!-- ## SSH Configuration

- Generate and add an SSH key for GitHub integration, following the [official guide](https://help.github.com/articles/connecting-to-github-with-ssh/). -->

## System Preferences (maybe deprecated thanks to `defaults write`)

- **Display**: Adjust to `More Space` for a broader workspace.
- **True Tone**: Disable this feature to maintain consistent colour accuracy.
- **Trackpad**: Enable `Use trackpad for dragging` with `Three-Finger Drag`.
- **Lock Screen**: Set the lock screen to require a password immediately after sleep or screen saver begins.
- **FileVault**: Enable FileVault for enhanced disk encryption and data protection.
- **Keyboard Shortcuts**: Disable most keyboard shortcuts to minimise accidental triggers.

## Dock Preferences

- Set Finder to appear on all desktops ("Options > All Desktops") for consistent navigation across virtual spaces.

## Firefox

- **Initial Setup**: Launch Firefox, close it after 5 seconds, and run the command `£ firefox-settings` to configure default settings. Relaunch Firefox and log into your sync account for access to bookmarks and preferences.
- **GUI Customisation**:
  - Customise the GUI for a personalised browser layout.
  - Set Gmail as the default mail client for email links.
  - Enable Google auto-search functionality by adding `!g`.

![](./firefox.png)

## Visual Studio Code

- Enable settings sync via GitHub to access your workspace preferences anywhere.

## KeePassXC

<!-- - Configure the theme to `dark` for a sleek appearance. -->

- Set up the KeePassXC Browser Addon for secure password management integration.

## iTerm2

- Import and load your data/settings for a seamless terminal configuration.

## Raycast

- Log in to your account and enable sync to access personalised settings across devices.
- Choose the `Linear` theme for a clean user interface.

## Spotify

- Set the `Jazz` preset for an optimised listening experience.

## Slack

- Change the font family to `Helvetica` using the command `/slackfont Helvetica` for a refined chat interface.

## earsafe

- Install [earsafe](https://kristofdombi.gumroad.com/l/earsafe) to monitor and manage sound levels for hearing safety.

## pCloud

- Configure ignored file patterns to optimise syncing and storage:
  ```
  .ds_store; .ds_store?; .appledouble; ._*; .spotlight-v100; .documentrevisions-v100;
  .temporaryitems; .trashes; .fseventsd; .~lock.*; ehthumbs.db; thumbs.db;
  hiberfil.sys; pagefile.sys; $recycle.bin; *.part; .pcloud; node_modules; .stfolder;
  ```

## DNSCrypt-Proxy

- Update the configuration to use the following settings for secure DNS resolution:

```toml
server_names = ['rethinkdns-doh', 'rethinkdns-doh-max']

[static]
  [static.'rethinkdns-doh']
    stamp = 'sdns://AgYAAAAAAAAAACBdzvEcz84tL6QcR78t69kc0nufblyYal5di10An6SyUBJza3kucmV0aGlua2Rucy5jb20KL2Rucy1xdWVyeQ'

  [static.'rethinkdns-doh-max']
    stamp = 'sdns://AgYAAAAAAAAAACCaOjT3J965vKUQA9nOnDn48n3ZxSQpAcK6saROY1oCGRJtYXgucmV0aGlua2Rucy5jb20KL2Rucy1xdWVyeQ'
```

- `sudo networksetup -setdnsservers "Wi-Fi" 127.0.0.1`

<!-- ## Screensaver

- Choose the `fliqlo` screensaver for a minimalist clock display. -->
