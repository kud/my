# Post-Installation Configuration Guide

Ce document sert de guide de configuration détaillé, décomposant chaque étape de configuration et ajustement des préférences pour les applications logicielles et les préférences système après une nouvelle installation dans un tableau unifié.

## Table des Matières

- [Applications Générales](#applications-générales)
  - [KeePassXC](#keepassxc)
  - [Raycast](#raycast)
  - [Hyperkey](#hyperkey)
  - [Firefox](#firefox)
  - [Spotify](#spotify)
  - [iTerm2](#iterm2)
  - [Visual Studio Code](#visual-studio-code)
  - [Sublime Merge](#sublime-merge)
  - [Slack](#slack)
  - [Applications](#applications)
- [Configuration SSH](#configuration-ssh)
- [Configuration de Projet](#configuration-de-projet)
- [Dock](#dock)
- [Préférences Système](#préférences-système)
- [Table des Raccourcis](#table-des-raccourcis)
- [Configurations Supplémentaires](#configurations-supplémentaires)

## Configuration Table

| Applications                  | Catégorie             | Actions                                                                                                                                                  |
| ----------------------------- | --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **KeePassXC**                 | Theme                 | Set to `dark`                                                                                                                                            |
|                               | Browser Addon         | Setup KeePassXC Browser Addon                                                                                                                            |
| **Raycast**                   | Account               | Log in and enable sync                                                                                                                                   |
|                               | Appearance            | Set to `Linear` Theme                                                                                                                                    |
| **Hyperkey**                  | Setup                 | Complete setup according to preferences                                                                                                                  |
| **Firefox**                   | Setup & Configuration | 1. Launch Firefox, then close it after 5 seconds.<br>2. Execute the command `£ firefox-settings`.<br>3. Relaunch Firefox and log into your sync account. |
|                               | GUI Customization     | Customize the GUI                                                                                                                                        |
|                               | Default Mail Client   | Set Gmail as the default mail client                                                                                                                     |
|                               | Google Auto-Search    | Add `!g` for Google auto-search                                                                                                                          |
| **Spotify**                   | Presets               | Select `Jazz` as preset                                                                                                                                  |
| **iTerm2**                    | Import Settings       | Import and load data/settings                                                                                                                            |
| **Visual Studio Code**        | Settings Sync         | Enable settings sync via GitHub                                                                                                                          |
| **Slack**                     | Font Family           | Change the font family to `Helvetica` using the `/slackfont Helvetica` command                                                                           |
| **Applications**              | Hearing Protection    | Install [earsafe](https://earsafe.io/) for hearing protection                                                                                            |
| **SSH Configuration**         | SSH Key               | Add SSH key for GitHub integration as per the [official guide](https://help.github.com/articles/connecting-to-github-with-ssh/)                          |
| **Project Configuration**     | Remote URL            | Navigate to the project directory and change the remote URL to GitHub using SSH: `cd MY && git remote set-url origin git@github.com:kud/my.git`          |
| **Dock**                      | Finder                | Set: Options > All Desktops. Useful if you use different desktops                                                                                        |
| **System Preferences**        | Screen Real Estate    | Adjust to `More Space`                                                                                                                                   |
|                               | True Tone             | Disable this feature                                                                                                                                     |
|                               | Trackpad Options      | Enable `Use trackpad for dragging` with `Three-Finger Drag`                                                                                              |
|                               | Lock Screen           | Set to require password `immediately` after sleep or screen saver begins                                                                                 |
|                               | FileVault             | Enable FileVault for disk encryption                                                                                                                     |
|                               | Shortcuts             | Disable (almost) all the keyboard shortcuts                                                                                                              |
| **Hotkeys Table**             | PixelSnap             | Hyperkey + `P`                                                                                                                                           |
|                               | Pika                  | Hyperkey + `I`                                                                                                                                           |
| **Additional Configurations** | Screensaver           | Set the screensaver to `fliqlo`                                                                                                                          |
