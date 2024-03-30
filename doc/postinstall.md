# Post-Installation Configuration Guide

This document serves as a detailed configuration guide, breaking down each setup step and preference adjustment for software applications and system preferences after a new installation into dedicated tables for each category.

## Table of Contents

- [General Applications](#general-applications)
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
- [SSH Configuration](#ssh-configuration)
- [Project Configuration](#project-configuration)
- [Dock](#dock)
- [System Preferences](#system-preferences)
- [Hotkeys Table](#hotkeys-table)
- [Additional Configurations](#additional-configurations)

## General Applications

### KeePassXC

| Action        | Description                   |
| ------------- | ----------------------------- |
| Theme         | Set to `dark`                 |
| Browser Addon | Setup KeePassXC Browser Addon |

### Raycast

| Action     | Description            |
| ---------- | ---------------------- |
| Account    | Log in and enable sync |
| Appearance | Set to `Linear` Theme  |

### Hyperkey

| Action | Description                             |
| ------ | --------------------------------------- |
| Setup  | Complete setup according to preferences |

### Firefox

| Action                | Description                                                                                                                                              |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Setup & Configuration | 1. Launch Firefox, then close it after 5 seconds.<br>2. Execute the command `£ firefox-settings`.<br>3. Relaunch Firefox and log into your sync account. |
| GUI Customization     | Customize the GUI                                                                                                                                        |
| Default Mail Client   | Set Gmail as the default mail client                                                                                                                     |
| Google Auto-Search    | Add `!g` for Google auto-search                                                                                                                          |

### Spotify

| Action  | Description             |
| ------- | ----------------------- |
| Presets | Select `Jazz` as preset |

### iTerm2

| Action          | Description                   |
| --------------- | ----------------------------- |
| Import Settings | Import and load data/settings |

### Visual Studio Code

| Action        | Description                     |
| ------------- | ------------------------------- |
| Settings Sync | Enable settings sync via GitHub |

### Sublime Merge

| Action | Description                                                                                |
| ------ | ------------------------------------------------------------------------------------------ |
| Theme  | Install the Meetio Theme from [GitHub](https://github.com/meetio-theme/merge-meetio-theme) |

### Slack

| Action      | Description                                                                    |
| ----------- | ------------------------------------------------------------------------------ |
| Font Family | Change the font family to `Helvetica` using the `/slackfont Helvetica` command |

### Applications

| Action             | Description                                                   |
| ------------------ | ------------------------------------------------------------- |
| Hearing Protection | Install [earsafe](https://earsafe.io/) for hearing protection |

## SSH Configuration

| Action  | Description                                                                                                                     |
| ------- | ------------------------------------------------------------------------------------------------------------------------------- |
| SSH Key | Add SSH key for GitHub integration as per the [official guide](https://help.github.com/articles/connecting-to-github-with-ssh/) |

## Project Configuration

| Action     | Description                                                                                                                                     |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| Remote URL | Navigate to the project directory and change the remote URL to GitHub using SSH: `cd MY && git remote set-url origin git@github.com:kud/my.git` |

## Dock

| Action | Description                                                       |
| ------ | ----------------------------------------------------------------- |
| Finder | Set: Options > All Desktops. Useful if you use different desktops |

## System Preferences

| Category           | Action             | Description                                                              |
| ------------------ | ------------------ | ------------------------------------------------------------------------ |
| Display            | Screen Real Estate | Adjust to `More Space`                                                   |
| Display            | True Tone          | Disable this feature                                                     |
| Accessibility      | Trackpad Options   | Enable `Use trackpad for dragging` with `Three-Finger Drag`              |
| Privacy & Security | Lock Screen        | Set to require password `immediately` after sleep or screen saver begins |
| Privacy & Security | FileVault          | Enable FileVault for disk encryption                                     |
| Keyboard           | Shortcuts          | Disable (almost) all the keyboard shortcuts                              |

## Hotkeys Table

| Application | Hotkey         |
| ----------- | -------------- |
| PixelSnap   | Hyperkey + `P` |
| Pika        | Hyperkey + `I` |

## Additional Configurations

### Screensaver

| Action | Description                     |
| ------ | ------------------------------- |
| Set    | Set the screensaver to `fliqlo` |

<!-- ### System Integrity Protection

| Action    | Description                                                                                                                                                                      |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Configure | To disable or configure SIP, restart in recovery mode (cmd + r), open Terminal from Utilities, and execute <br> `$ csrutil enable --without fs`. <br>Then restart your computer. | -->
