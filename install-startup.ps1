# Signal Deck - run at Windows startup
#
# Puts a shortcut in your Startup folder so Signal Deck opens in its own app
# window every time you log in. The reminder timer only runs while the app is
# open, so this is what makes the 3 daily nudges actually fire.
#
# Run:      right-click this file -> "Run with PowerShell"
# Undo:     .\install-startup.ps1 -Remove

param([switch]$Remove)

$ErrorActionPreference = "SilentlyContinue"

$url      = "https://aniketsingh12.github.io/dailytask/"
$startup  = [Environment]::GetFolderPath("Startup")
$lnkPath  = Join-Path $startup "Signal Deck.lnk"

if ($Remove) {
  if (Test-Path $lnkPath) {
    Remove-Item $lnkPath -Force
    Write-Host "Removed Signal Deck from startup."
  } else {
    Write-Host "Signal Deck was not in your startup folder - nothing to remove."
  }
  exit
}

$chromePath = "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
$bravePath  = "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe"
$edgePath   = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"

$browserPath = $null
if (Test-Path $bravePath)      { $browserPath = $bravePath }
elseif (Test-Path $chromePath) { $browserPath = $chromePath }
elseif (Test-Path $edgePath)   { $browserPath = $edgePath }

if (-not $browserPath) {
  Write-Host "Couldn't find Chrome, Brave, or Edge in their usual install locations."
  Write-Host "Open $url manually and use the browser's own Install option instead."
  exit
}

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($lnkPath)
$shortcut.TargetPath   = $browserPath
$shortcut.Arguments    = "--app=`"$url`""
$shortcut.IconLocation = $browserPath
$shortcut.Description  = "Signal Deck - daily priorities"
$shortcut.Save()

Write-Host ""
Write-Host "Done. Signal Deck will now open automatically when you log in."
Write-Host "Shortcut: $lnkPath"
Write-Host ""
Write-Host "Two things to finish setup:"
Write-Host "  1. Open the app once and turn Reminders on (allow notifications when asked)."
Write-Host "  2. Leave the window open or minimised - nudges only fire while it's running."
Write-Host ""
Write-Host "To undo later:  .\install-startup.ps1 -Remove"
