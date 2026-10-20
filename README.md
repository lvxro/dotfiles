# dotfiles — Red Balloon

My Windows 11 rice: a [YASB](https://github.com/amnweb/yasb) bar, [Windhawk](https://windhawk.net) mods, Windows Terminal and fastfetch, all sharing one palette taken from the wallpaper: night teal, cream, peach and the red of the balloons.

![wallpaper](wallpaper/red-balloon.jpg)

## What's inside

| File | Purpose |
|---|---|
| `config.yaml` | YASB widgets and layout |
| `styles.css` | Red Balloon theme (also includes a commented-out day variant) |
| `wallpaper/red-balloon.jpg` | The wallpaper the palette is based on |
| `windhawk/*.ini` | Settings for each Windhawk mod |
| `terminal/red-balloon.json` | Windows Terminal color scheme, tab theme and profile defaults |
| `powershell/` | Prompt colors and the profile snippet that runs fastfetch |
| `fastfetch/` | fastfetch config and the sixel logo |
| `windows/accent.reg` | Balloon-red accent color for Windows |
| `helium/` | Chromium theme (works in Helium, Chrome, Brave…) with a gradient new-tab page |
| `vscode/` | Red Balloon color theme for VS Code (source and `.vsix`) |

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

### Windhawk

Install [Windhawk](https://windhawk.net) and these mods from its Explore tab:

| Mod | What it does here |
|---|---|
| Windows 11 File Explorer Styler | TintedGlass theme tinted with the bar's teal |
| Translucent Windows | Teal blur behind Explorer, context menus and classic windows |
| Windows 11 Notification Center Styler | TintedGlass in teal, peach accent, 12px corners |
| Better file sizes in Explorer details | Folder sizes via [Everything](https://www.voidtools.com/) (enable *Index folder size* in its options) |
| Customize Windows notifications placement | Toasts appear top-right, just below the bar |
| Taskbar auto-hide fine tuning | Mode *Never*: the Windows taskbar never shows, YASB replaces it. Needs taskbar auto-hide on. `` Alt+` `` toggles it back if you need it |

For each mod, open **Details → Settings → Advanced** and paste the matching file from `windhawk/`.

If you use the portable Windhawk and later move its folder, the notification mods stop working: `ShellExperienceHost.exe` runs sandboxed and loses read access to the mods. Give it back with:

```powershell
icacls "<Windhawk folder>\AppData\Engine" /grant "*S-1-15-2-1:(OI)(CI)(RX)" "*S-1-15-2-2:(OI)(CI)(RX)"
```

### Terminal, PowerShell and fastfetch

1. Install [fastfetch](https://github.com/fastfetch-cli/fastfetch) (`winget install fastfetch`). [Starship](https://starship.rs) is optional; without it the prompt in `powershell/prompt.ps1` is used.
2. Copy `fastfetch/` to `%USERPROFILE%\.config\fastfetch\` and `powershell/prompt.ps1` to `%USERPROFILE%\.config\red-balloon\prompt.ps1`.
3. Append `powershell/profile.ps1` to your `$PROFILE`.
4. In Windows Terminal, open **Settings → Open JSON file** and merge in `terminal/red-balloon.json`. The logo is drawn with sixel, which needs Windows Terminal 1.22 or newer.

### Browser and editor

- **Browser:** open `chrome://extensions`, turn on Developer mode, click **Load unpacked** and pick the `helium/` folder.
- **VS Code:** run `code --install-extension vscode/red-balloon.vsix`, then pick **Red Balloon** in *Preferences: Color Theme*.

### Accent color

Double-click `windows/accent.reg`, then sign out and back in so every part of Windows picks up the new accent.

## Things you may want to change

- **Spotifast:** `active_window.ignore_window` excludes `spotifast.exe`, since the current song is already shown in the music island. If you use Spotify, change it to `Spotify.exe`.
- **Day theme:** in `styles.css`, comment out the "Red Balloon (night)" block and uncomment the "(day)" one.
- **Time-only clock:** in `config.yaml`, set the `clock` `label` to `'{%H:%M}<span>{alarm}</span>'`.

## Credits

The wallpaper and the fastfetch logo are not mine; all credit goes to the original artist. If you know who made them, let me know and I'll add it here.
