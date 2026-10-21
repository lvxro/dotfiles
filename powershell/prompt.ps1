# Night Balcony — PowerShell colors (fallback prompt when Starship is not installed)
# Loaded from your profile with:  . "$HOME\.config\night-balcony\prompt.ps1"

$global:RBE = [char]27
function global:RBRgb([int]$r, [int]$g, [int]$b) { "$global:RBE[38;2;${r};${g};${b}m" }

$global:RBC = @{
    Line   = RBRgb 90 106 153     # dim haze  #5A6A99
    Path    = RBRgb 111 164 255    # blue        #6FA4FF
    Ok      = RBRgb 134 214 192     # sea glass  #5DBFA5
    Error   = RBRgb 240 122 143    # rose red     #F07A8F
    Reset   = "$global:RBE[0m"
}

# Glyphs by code point so they do not depend on file encoding
$global:RBG = @{
    Top = [string][char]0x256D + [char]0x2500   # ╭─
    Bottom  = [string][char]0x2570 + [char]0x2500   # ╰─
    Arrow = [string][char]0x276F                  # ❯
}

if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
function global:prompt {
    $ok = $?
    $Path = $PWD.Path
    if ($Path.StartsWith($HOME, [System.StringComparison]::OrdinalIgnoreCase)) {
        $Path = '~' + $Path.Substring($HOME.Length)
    }
    $Arrow = if ($ok) { $global:RBC.Ok } else { $global:RBC.Error }
    "$($global:RBC.Line)$($global:RBG.Top) $($global:RBC.Path)$Path$($global:RBC.Reset)`n" +
    "$($global:RBC.Line)$($global:RBG.Bottom)$Arrow$($global:RBG.Arrow)$($global:RBC.Reset) "
}
}  # with Starship installed, Starship draws the prompt from ~/.config/starship.toml

# Input colors (PSReadLine)
try {
    Set-PSReadLineOption -Colors @{
        Command   = RBRgb 111 164 255   # blue
        Parameter = RBRgb 163 180 224   # haze
        String    = RBRgb 134 214 192   # sea glass
        Variable  = RBRgb 94 200 240   # sky blue
        Number    = RBRgb 240 196 138   # amber
        Operator  = RBRgb 163 180 224
        Comment   = RBRgb 90 106 153
        Keyword   = RBRgb 155 130 255   # eye violet
        Error     = RBRgb 240 122 143   # rose
        Default   = RBRgb 223 230 251   # moonlight
    }
} catch { }
