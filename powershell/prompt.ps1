# Red Balloon — PowerShell colors (fallback prompt when Starship is not installed)
# Loaded from your profile with:  . "$HOME\.config\red-balloon\prompt.ps1"

$global:RBE = [char]27
function global:RBRgb([int]$r, [int]$g, [int]$b) { "$global:RBE[38;2;${r};${g};${b}m" }

$global:RBC = @{
    Line   = RBRgb 94 130 133     # dark sage  #5E8285
    Path    = RBRgb 252 204 168    # peach        #FCCCA8
    Ok      = RBRgb 68 175 155     # cloud mint  #44AF9B
    Error   = RBRgb 255 107 107    # balloon red  #FF6B6B
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
        Command   = RBRgb 252 204 168   # peach
        Parameter = RBRgb 169 203 193   # sage
        String    = RBRgb 127 224 200   # light mint
        Variable  = RBRgb 159 211 230   # sky blue
        Number    = RBRgb 245 185 113   # amber
        Operator  = RBRgb 169 203 193
        Comment   = RBRgb 94 130 133
        Keyword   = RBRgb 227 163 168   # skin pink
        Error     = RBRgb 255 107 107   # crimson
        Default   = RBRgb 244 230 218   # cream
    }
} catch { }
