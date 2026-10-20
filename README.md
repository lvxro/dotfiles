# dotfiles — Red Balloon

My [YASB](https://github.com/amnweb/yasb) bar for Windows 11. The palette comes from the wallpaper: night teal, cream, peach and the red of the balloons.

![wallpaper](wallpaper/red-balloon.jpg)

## What's inside

| File | Purpose |
|---|---|
| `config.yaml` | YASB widgets and layout |
| `styles.css` | Red Balloon theme (also includes a commented-out day variant) |
| `wallpaper/red-balloon.jpg` | The wallpaper the palette is based on |

## The bar

- **Left:** `家` button (folder menu) and the active window (app name only).
- **Center:** clock `Mon 19 · 21:14`. Left click opens the calendar; right click shows the full date.
- **Right:**
  - Music island: controls, title and artist, and an audio visualizer. It hides itself when nothing is playing.
  - System island: weather, system tray, volume, notifications and control center.
- **Alt + Space:** app launcher. The search button is hidden, but the shortcut still works.

## Installation

1. Install [YASB](https://github.com/amnweb/yasb/releases).
2. Install the fonts:
   - [Zen Kaku Gothic New](https://fonts.google.com/specimen/Zen+Kaku+Gothic+New) for all bar text (Latin and Japanese).
   - [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads) for the icons.
3. Clone this repo into `%USERPROFILE%\.config\yasb\`:

   ```powershell
   git clone https://github.com/lvxro/dotfiles "$env:USERPROFILE\.config\yasb"
   ```

4. Set the image in `wallpaper/` as your desktop background.
5. In Settings → Personalization → Taskbar, turn on **Automatically hide the taskbar**.
6. Restart YASB (`yasbc reload`).

## Things you may want to change

- **Spotifast:** `active_window.ignore_window` excludes `spotifast.exe`, since the current song is already shown in the music island. If you use Spotify, change it to `Spotify.exe`.
- **Day theme:** in `styles.css`, comment out the "Red Balloon (night)" block and uncomment the "(day)" one.
- **Time-only clock:** in `config.yaml`, set the `clock` `label` to `'{%H:%M}<span>{alarm}</span>'`.

## Credits

The wallpaper is not mine; all credit goes to the original artist. If you know who made it, let me know and I'll add it here.
