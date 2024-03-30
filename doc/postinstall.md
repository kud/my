# Post-Installation Configuration Guide

This guide outlines the proper steps and adjustments necessary for setting up your software applications and system preferences after a new installation.

## General Applications

### KeePassXC

- **Theme:** Set to dark.
- **Browser Addon:** Setup KeePassXC Browser Addon.

### Raycast

- **Account:** Log in and enable sync.
- **Appearance:** Set to Linear Theme.

### Hyperkey

- Complete setup according to preferences.

### Firefox

- Launch Firefox, then close it after 5 seconds.
- Execute the command `£ firefox-settings`.
- Relaunch Firefox, log into sync account.
- Customize the GUI
- Set Gmail as the default mail client.
- Add "!g" for Google auto-search.

### Spotify

- **Presets:** Select the Jazz presets.

### iTerm2

- Import and load data/settings.

### SSH Configuration

- Add SSH key for GitHub integration as per the [official guide](https://help.github.com/articles/connecting-to-github-with-ssh/).

### Project Configuration

- Navigate to the project directory and change the remote URL to GitHub using SSH:
  ```
  cd MY && git remote set-url origin git@github.com:kud/my.git
  ```

### Dock

- For Finder, set: Options > All Desktops. This is useful if you use different desktops

### Visual Studio Code

- Enable settings sync via GitHub ### Sublime Merge
- Install the Meetio Theme from [GitHub](https://github.com/meetio-theme/merge-meetio-theme).

### Slack

- Change the font family to Helvetica using the `/slackfont Helvetica` command.

### Applications

- Install [earsafe](https://earsafe.io/) for hearing protection.

## System Preferences

### Display

- **Screen Real Estate:** Adjust to "More Space."
- **True Tone:** Disable this feature.

### Accessibility

- **Trackpad Options:** Enable "Use trackpad for dragging" with "Three-Finger Drag."

### Privacy & Security

- **Lock Screen:** Set to require password "immediately" after sleep or screen saver begins.
- **FileVault:** Enable FileVault for disk encryption.

### Keyboard

- **Shortcuts:** Disable (almost) all the keyboard shortcuts.

## Hotkeys Table

| Application | Hotkey       |
| ----------- | ------------ |
| PixelSnap   | Hyperkey + P |
| Pika        | Hyperkey + I |

## Additional Configurations

### Screensaver

- Set the screensaver to `fliqlo`.

### System Integrity Protection

- To disable or configure SIP, restart in recovery mode (cmd + r), open Terminal from Utilities, and execute `$ csrutil enable --without fs`. Then restart your computer
