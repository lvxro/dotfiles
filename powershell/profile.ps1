# Add to your PowerShell profile ($PROFILE)
if (Get-Command starship -ErrorAction SilentlyContinue) { Invoke-Expression (&starship init powershell) }
. "$HOME\.config\red-balloon\prompt.ps1"
if ((Get-Command fastfetch -ErrorAction SilentlyContinue) -and $env:WT_SESSION) { fastfetch -c "$HOME\.config\fastfetch\red-balloon.jsonc" }
