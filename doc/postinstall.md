# Post-Installation Configuration Guide

## Applications

### KeePassXC

- Set the theme to `dark`.
- Configure the KeePassXC Browser Addon.

### Raycast

- Log in and enable sync.
- Set the theme to `Linear`.

### Hyperkey

- Complete the setup according to your preferences.

### Firefox

#### Initial Setup

- Launch Firefox, close it after 5 seconds, and execute the command `£ firefox-settings`.
- Relaunch Firefox and log into your sync account.

#### GUI Customisation

- Customise the GUI and set Gmail as the default mail client.
- Add `!g` for Google auto-search functionality.

![](./firefox.png)

### Spotify

- Select `Jazz` as the preset.

### iTerm2

- Import and load data/settings.

### Visual Studio Code

- Enable settings sync via GitHub.

### Slack

- Change the font family to `Helvetica` by running `/slackfont Helvetica`.

### Hearing Protection

- Install [earsafe](https://earsafe.io/) for hearing protection.

## Configuration and Preferences

### SSH Configuration

- Add an SSH key for GitHub integration following the [official guide](https://help.github.com/articles/connecting-to-github-with-ssh/).

### Project Configuration

- Navigate to the project directory and update the remote URL to GitHub using SSH:
  ```bash
  cd MY
  git remote set-url origin git@github.com:kud/my.git
  ```

### Dock Preferences

- Set Finder to "Options > All Desktops" for a consistent experience across multiple desktops.

### System Preferences

#### Display

- Adjust the display to `More Space`.

#### True Tone

- Disable True Tone.

#### Trackpad

- Enable `Use trackpad for dragging` with `Three-Finger Drag`.

#### Lock Screen

- Set the lock screen to require a password immediately after sleep or screen saver begins.

#### FileVault

- Enable FileVault for disk encryption.

#### Keyboard Shortcuts

- Disable most keyboard shortcuts.

## Hotkeys

### PixelSnap

- Hyperkey + `P`

### Pika

- Hyperkey + `I`

## Additional Configurations

### Screensaver

- Set the screensaver to `fliqlo`.

### pCloud Ignore Files

- Configure the following patterns to be ignored:
  ```
  .ds_store; .ds_store?; .appledouble; ._*; .spotlight-v100; .documentrevisions-v100;
  .temporaryitems; .trashes; .fseventsd; .~lock.*; ehthumbs.db; thumbs.db;
  hiberfil.sys; pagefile.sys; $recycle.bin; *.part; .pcloud; node_modules; .stfolder;
  ```

## DNSCrypt-Proxy Configuration

Update the `dnscrypt-proxy` configuration as follows:

```toml
server_names = ['rethinkdns-doh', 'rethinkdns-doh-max']

[static]
  [static.'rethinkdns-doh']
    stamp = 'sdns://AgYAAAAAAAAAACBdzvEcz84tL6QcR78t69kc0nufblyYal5di10An6SyUBJza3kucmV0aGlua2Rucy5jb20KL2Rucy1xdWVyeQ'

  [static.'rethinkdns-doh-max']
    stamp = 'sdns://AgYAAAAAAAAAACCaOjT3J965vKUQA9nOnDn48n3ZxSQpAcK6saROY1oCGRJtYXgucmV0aGlua2Rucy5jb20KL2Rucy1xdWVyeQ'
```

Then use `127.0.0.1` as DNS in your network configuration.
