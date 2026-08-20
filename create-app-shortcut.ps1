# Signal Deck - desktop shortcut
#
# Creates a Desktop shortcut that opens Signal Deck in its own app window
# (no address bar). Signal Deck is hosted on GitHub Pages now, so there's
# no local server involved.
#
# Run: right-click this file -> "Run with PowerShell"

$ErrorActionPreference = "SilentlyContinue"

$url     = "https://aniketsingh12.github.io/dailytask/"
$desktop = [Environment]::GetFolderPath("Desktop")
$lnkPath = Join-Path $desktop "Signal Deck.lnk"

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

Write-Host "Created shortcut on your Desktop: $lnkPath"
Write-Host "To have it open automatically at login instead, run: .\install-startup.ps1"
