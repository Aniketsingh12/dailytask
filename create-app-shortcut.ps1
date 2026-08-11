$ErrorActionPreference = "SilentlyContinue"

$launcher = Join-Path $PSScriptRoot "start-signal-deck.vbs"
$desktop = [Environment]::GetFolderPath("Desktop")
$lnkPath = Join-Path $desktop "Signal Deck.lnk"

$iconSource = $null
$chromePath = "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
$bravePath  = "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe"
if (Test-Path $bravePath) { $iconSource = $bravePath }
elseif (Test-Path $chromePath) { $iconSource = $chromePath }

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($lnkPath)
$shortcut.TargetPath = "wscript.exe"
$shortcut.Arguments = "`"$launcher`""
$shortcut.WorkingDirectory = $PSScriptRoot
if ($iconSource) { $shortcut.IconLocation = $iconSource }
$shortcut.Description = "Signal Deck"
$shortcut.Save()

Write-Host "Created shortcut on your Desktop: $lnkPath"
Write-Host "Double-click it any time - it starts the local server quietly and opens Signal Deck as its own app window."
Write-Host "Notification permission will now persist normally since it's served over localhost, not a local file."
