<#
.SYNOPSIS
    Installs the Night Balcony rice: copies every config in this repo to where its app expects it.

.DESCRIPTION
    Run it from the repo root (ideally cloned to %USERPROFILE%\.config\yasb).
    Each step is skipped when its app is not installed. Files that already exist are
    backed up as <name>.bak before being replaced. Use -DryRun to see what would happen.

.EXAMPLE
    .\install.ps1 -DryRun
    .\install.ps1
    .\install.ps1 -Only terminal,discord
#>
param(
    [switch]$DryRun,
    [string[]]$Only = @()
)

$ErrorActionPreference = 'Stop'
# "-Only a,b" arrives as one string when run with powershell -File
$Only = @($Only | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$Repo = $PSScriptRoot
$Home_ = $env:USERPROFILE

function Step($name) { return ($Only.Count -eq 0) -or ($Only -contains $name) }
function Say($msg, $color = 'Gray') { Write-Host $msg -ForegroundColor $color }
function Skip($msg) { Say "  - skipped: $msg" 'DarkGray' }

function Put($src, $dst) {
    $src = Join-Path $Repo $src
    if ($DryRun) { Say "  would copy $src -> $dst" 'DarkCyan'; return }
    New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
    if ((Test-Path $dst) -and -not (Test-Path "$dst.bak")) { Copy-Item $dst "$dst.bak" -Force }
    Copy-Item $src $dst -Force
    Say "  copied $(Split-Path $src -Leaf) -> $dst" 'Green'
}

# ---------------------------------------------------------------- YASB
if (Step 'yasb') {
    Say 'YASB' 'Cyan'
    $yasbDir = Join-Path $Home_ '.config\yasb'
    if ((Resolve-Path $Repo).Path -ne (Resolve-Path -ErrorAction SilentlyContinue $yasbDir).Path) {
        Put 'config.yaml' "$yasbDir\config.yaml"
        Put 'styles.css'  "$yasbDir\styles.css"
    } else { Say '  repo is already the YASB config folder' 'Green' }
}

# ---------------------------------------------------------------- Wallpaper
if (Step 'wallpaper') {
    Say 'Wallpaper' 'Cyan'
    $wp = Join-Path $Home_ 'Pictures\wallpapers\night-balcony.jpg'
    Put 'wallpaper\night-balcony.jpg' $wp
    if (-not $DryRun) {
        Add-Type -Namespace RB -Name Wp -MemberDefinition '[DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int SystemParametersInfo(int a, int b, string c, int d);'
        [RB.Wp]::SystemParametersInfo(20, 0, $wp, 3) | Out-Null
        Say '  set as desktop background' 'Green'
    }
}

# ---------------------------------------------------------------- Accent color
if (Step 'accent') {
    Say 'Accent color' 'Cyan'
    if ($DryRun) { Say '  would import windows\accent.reg (sign out afterwards)' 'DarkCyan' }
    # reg prints its success message to stderr, which Windows PowerShell turns into a terminating error under Stop
    else { cmd /c "reg import `"$(Join-Path $Repo 'windows\accent.reg')`" >nul 2>&1"; Say '  imported; apply it from Settings > Colors or sign out' 'Green' }
}

# ---------------------------------------------------------------- Windows Terminal
if (Step 'terminal') {
    Say 'Windows Terminal' 'Cyan'
    $wt = Get-ChildItem "$env:LOCALAPPDATA\Packages" -Directory -Filter 'Microsoft.WindowsTerminal*' -ErrorAction SilentlyContinue |
          ForEach-Object { Join-Path $_.FullName 'LocalState\settings.json' } | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $wt) { Skip 'Windows Terminal settings not found' }
    elseif ($DryRun) { Say "  would merge terminal\night-balcony.json into $wt" 'DarkCyan' }
    else {
        Copy-Item $wt "$wt.bak" -Force
        $s = Get-Content $wt -Raw | ConvertFrom-Json
        $f = Get-Content (Join-Path $Repo 'terminal\night-balcony.json') -Raw | ConvertFrom-Json
        foreach ($p in $f.profiles.defaults.PSObject.Properties) {
            $s.profiles.defaults | Add-Member -NotePropertyName $p.Name -NotePropertyValue $p.Value -Force
        }
        $s.schemes = @($s.schemes | Where-Object { $_.name -ne 'Night Balcony' }) + $f.schemes
        # @() outside the if: an if statement unrolls a one-item array into a bare object
        $themes = @(if ($s.PSObject.Properties['themes']) { $s.themes | Where-Object { $_.name -ne 'Night Balcony' } })
        $s | Add-Member -NotePropertyName themes -NotePropertyValue ($themes + $f.themes) -Force
        $s | Add-Member -NotePropertyName theme -NotePropertyValue 'Night Balcony' -Force
        $s | ConvertTo-Json -Depth 20 | Set-Content $wt -Encoding UTF8
        Say "  merged scheme, theme and defaults (backup: settings.json.bak)" 'Green'
    }
}

# ---------------------------------------------------------------- PowerShell prompt + fastfetch
if (Step 'shell') {
    Say 'PowerShell and fastfetch' 'Cyan'
    Put 'powershell\prompt.ps1'         "$Home_\.config\night-balcony\prompt.ps1"
    Put 'fastfetch\night-balcony.jsonc'   "$Home_\.config\fastfetch\night-balcony.jsonc"
    Put 'fastfetch\logo.png'            "$Home_\.config\fastfetch\logo.png"
    $marker = '# >>> night-balcony'
    # drop the snippet left by the previous theme, so the prompt is not loaded twice
    if ((Test-Path $PROFILE) -and (Select-String -Path $PROFILE -SimpleMatch '# >>> red-balloon' -Quiet)) {
        if ($DryRun) { Say '  would remove the old red-balloon snippet from the profile' 'DarkCyan' }
        else {
            Copy-Item $PROFILE "$PROFILE.bak" -Force
            $old = (Get-Content $PROFILE -Raw) -replace '(?s)\r?\n?# >>> red-balloon.*?# <<< red-balloon\r?\n?', "`r`n"
            Set-Content $PROFILE $old.TrimEnd() -Encoding UTF8
            Say '  removed the old red-balloon snippet (backup: profile .bak)' 'Green'
        }
    }
    if ((Test-Path $PROFILE) -and (Select-String -Path $PROFILE -SimpleMatch $marker -Quiet)) { Say '  profile already has the snippet' 'Green' }
    elseif ($DryRun) { Say "  would append powershell\profile.ps1 to $PROFILE" 'DarkCyan' }
    else {
        New-Item -ItemType Directory -Force (Split-Path $PROFILE) | Out-Null
        $body = (Get-Content (Join-Path $Repo 'powershell\profile.ps1') | Where-Object { $_ -notmatch '^# Add to' }) -join "`r`n"
        Add-Content $PROFILE "`r`n$marker`r`n$body`r`n# <<< night-balcony"
        Say "  appended snippet to $PROFILE" 'Green'
    }
    if (-not (Get-Command fastfetch -ErrorAction SilentlyContinue)) { Say '  note: fastfetch is not installed (winget install fastfetch)' 'Yellow' }
}

# ---------------------------------------------------------------- btop
if (Step 'btop') {
    Say 'btop' 'Cyan'
    # winget puts a "btop" link in its Links folder; the theme must go next to the real exe
    $btop = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter btop4win.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $btop) { $btop = Get-Command btop4win -ErrorAction SilentlyContinue | ForEach-Object { Get-Item $_.Source } }
    if (-not $btop) { Skip 'btop4win not installed (winget install aristocratos.btop4win)' }
    else {
        $dir = $btop.DirectoryName
        Put 'btop\night-balcony.theme' "$dir\themes\night-balcony.theme"
        $conf = Join-Path $dir 'btop.conf'
        if ($DryRun) { Say "  would set color_theme in $conf" 'DarkCyan' }
        elseif (Test-Path $conf) {
            (Get-Content $conf) -replace '^color_theme\s*=.*$', 'color_theme = "night-balcony"' | Set-Content $conf
            Say '  set color_theme = night-balcony' 'Green'
        } else { Say '  open btop once, then pick night-balcony in Options > Color theme' 'Yellow' }
    }
}

# ---------------------------------------------------------------- Windhawk
if (Step 'windhawk') {
    Say 'Windhawk' 'Cyan'
    $exe = (Get-Process windhawk -ErrorAction SilentlyContinue | Select-Object -First 1).Path
    if (-not $exe) { $exe = @("$env:LOCALAPPDATA\Programs\Windhawk\windhawk.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1 }
    $mods = if ($exe) { Join-Path (Split-Path $exe) 'AppData\Engine\Mods' }
    if (-not $mods -or -not (Test-Path $mods)) {
        Skip 'portable Windhawk not found; paste each windhawk\*.ini into the mod''s Advanced settings instead'
    } else {
        foreach ($f in Get-ChildItem (Join-Path $Repo 'windhawk') -Filter *.ini) {
            $target = Join-Path $mods $f.Name
            if (-not (Test-Path $target)) { Skip "$($f.BaseName) is not installed in Windhawk"; continue }
            if ($DryRun) { Say "  would apply $($f.Name)" 'DarkCyan'; continue }
            $cur = Get-Content $target -Encoding Unicode -Raw
            Copy-Item $target "$target.bak" -Force
            $head = $cur.Substring(0, $cur.IndexOf('[Settings]'))
            $head = $head -replace '(?m)^SettingsChangeTime=\d+', ("SettingsChangeTime=" + [DateTimeOffset]::UtcNow.ToUnixTimeSeconds())
            [IO.File]::WriteAllText($target, $head + (Get-Content $f.FullName -Raw), [Text.Encoding]::Unicode)
            Say "  applied $($f.BaseName)" 'Green'
        }
    }
}

# ---------------------------------------------------------------- Discord
if (Step 'discord') {
    Say 'Discord' 'Cyan'
    $any = $false
    foreach ($c in 'Equicord', 'Vencord', 'BetterDiscord') {
        $t = Join-Path $env:APPDATA "$c\themes"
        if (Test-Path $t) { Put 'discord\midnight-balcony.theme.css' "$t\midnight-balcony.theme.css"; $any = $true }
    }
    if ($any) { Say '  enable it in Settings > Themes' 'Yellow' } else { Skip 'no Equicord, Vencord or BetterDiscord found' }
}

# ---------------------------------------------------------------- Steam (Millennium)
if (Step 'steam') {
    Say 'Steam' 'Cyan'
    $mil = "${env:ProgramFiles(x86)}\Steam\millennium"
    if (-not (Test-Path $mil)) { Skip 'Millennium not installed' }
    else {
        $mt = "$mil\themes\Material-Theme"
        if (-not (Test-Path $mt)) {
            if ($DryRun) { Say '  would clone the Material theme' 'DarkCyan' }
            elseif (Get-Command git -ErrorAction SilentlyContinue) { cmd /c "git clone -q --depth 1 https://github.com/kuska1/Material-Theme `"$mt`" >nul 2>&1"; Say '  cloned the Material theme' 'Green' }
            else { Say '  install Material from steambrew.app/theme/ipYjqODds05KMcvh7QJn' 'Yellow' }
        }
        # palette and font live outside the theme's own files, so theme updates keep them
        Put 'steam\material\mods.css'       "$mt\mods.css"
        Put 'steam\material\customFont.css' "$mt\customFont.css"
        Put 'steam\quick.css' "$mil\config\quick.css"
        Say '  in Steam > Millennium > Themes pick Material, then set Color: Blue, Font: Custom and Use Modifications File: yes' 'Yellow'
    }
}

# ---------------------------------------------------------------- Starship, Flow Launcher, Tacky Borders
if (Step 'starship') {
    Say 'Starship' 'Cyan'
    Put 'starship\starship.toml' "$Home_\.config\starship.toml"
}
if (Step 'flow') {
    Say 'Flow Launcher' 'Cyan'
    $fl = Join-Path $env:APPDATA 'FlowLauncher'
    if (-not (Test-Path $fl)) { Skip 'Flow Launcher not installed (winget install Flow-Launcher.Flow-Launcher)' }
    else {
        Put 'flow-launcher\Night Balcony.xaml' "$fl\Themes\Night Balcony.xaml"
        Say '  pick Night Balcony in Flow settings > Appearance (Alt+Space opens it)' 'Yellow'
    }
}
if (Step 'borders') {
    Say 'Tacky Borders' 'Cyan'
    Put 'tacky-borders\config.yaml' "$Home_\.config\tacky-borders\config.yaml"
    if (-not (Test-Path "$env:LOCALAPPDATA\Programs\tacky-borders\tacky-borders.exe")) {
        Say '  note: download tacky-borders from github.com/lukeyou05/tacky-borders/releases' 'Yellow'
    }
}

# ---------------------------------------------------------------- Browser, VS Code, ZapFast
if (Step 'browser') {
    Say 'Browser theme' 'Cyan'
    # Chromium keeps a compiled copy of the theme next to it; drop it so the new colors are rebuilt
    $pak = "$Home_\.config\helium-theme\Cached Theme.pak"
    if ((Test-Path $pak) -and -not $DryRun) { Remove-Item $pak -Force }
    Put 'helium\manifest.json'   "$Home_\.config\helium-theme\manifest.json"
    $nt = "$Home_\.config\helium-newtab"
    foreach ($n in 'manifest.json', 'newtab.html', 'newtab.js', 'config.example.js', 'art.png') { Put "helium-newtab\$n" "$nt\$n" }
    if (-not (Test-Path "$nt\config.js")) {
        if ($DryRun) { Say '  would create config.js from config.example.js' 'DarkCyan' }
        else { (Get-Content "$nt\config.example.js" -Raw) -replace 'C:\\\\Users\\\\YOU', ("C:\\Users\\" + $env:USERNAME) | Set-Content "$nt\config.js"; Say '  created config.js: set your weather city there' 'Yellow' }
    }
    Say '  load both from chrome://extensions > Load unpacked (or press Reload on each): .config\helium-theme and .config\helium-newtab' 'Yellow'
}
if (Step 'vscode') {
    Say 'VS Code' 'Cyan'
    $code = Get-Command code -ErrorAction SilentlyContinue
    if (-not $code) { Skip 'code CLI not found' }
    elseif ($DryRun) { Say '  would install vscode\night-balcony.vsix' 'DarkCyan' }
    # through cmd: Node's deprecation warnings on stderr would stop the script under Stop
    else { cmd /c "`"$($code.Source)`" --install-extension `"$(Join-Path $Repo 'vscode\night-balcony.vsix')`" --force >nul 2>&1"; Say '  installed; pick Night Balcony in Color Theme' 'Green' }
}
if (Step 'zapfast') {
    Say 'ZapFast' 'Cyan'
    $z = Join-Path $env:APPDATA 'paolino\zapfast\config\themes'
    if (Test-Path $z) { Put 'zapfast\night-balcony.json' "$z\night-balcony.json"; Put 'zapfast\night-balcony-day.json' "$z\night-balcony-day.json" }
    else { Skip 'ZapFast not installed' }
}
if (Step 'spotifast') {
    Say 'Spotifast' 'Cyan'
    $sf = Join-Path $env:APPDATA 'paolino\spotifast\config\themes'
    if (Test-Path $sf) {
        Put 'spotifast\night-balcony.json' "$sf\night-balcony.json"; Put 'spotifast\night-balcony-day.json' "$sf\night-balcony-day.json"
        Say '  pick Night Balcony in Spotifast > Settings > Theme' 'Yellow'
    }
    else { Skip 'Spotifast not installed' }
}

# ---------------------------------------------------------------- Nilesoft Shell (needs admin)
if (Step 'nilesoft') {
    Say 'Nilesoft Shell' 'Cyan'
    $ns = "$env:ProgramFiles\Nilesoft Shell\imports\theme.nss"
    if (-not (Test-Path (Split-Path $ns))) { Skip 'Nilesoft Shell not installed' }
    elseif ($DryRun) { Say "  would copy nilesoft\theme.nss -> $ns (asks for admin)" 'DarkCyan' }
    else {
        $src = Join-Path $Repo 'nilesoft\theme.nss'
        Start-Process powershell -Verb RunAs -Wait -ArgumentList '-NoProfile', '-Command', "Copy-Item '$ns' '$ns.bak' -Force; Copy-Item '$src' '$ns' -Force"
        Say '  copied (Ctrl + right-click on the desktop reloads it)' 'Green'
    }
}

Say "`nDone. Restart YASB with: yasbc reload" 'Cyan'
