param([int]$Port = 8000)

# NOTE: run this in an Administrator PowerShell window.
# Binding to "+" (all network interfaces, not just localhost) requires elevated
# rights on Windows, or a one-time reservation via:
#   netsh http add urlacl url=http://+:8000/ user=Everyone
# Without one of those, phones on your WiFi won't be able to reach this server.

$root = $PSScriptRoot
$stateFile = Join-Path $root "tasks.json"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:$Port/")
try {
  $listener.Start()
} catch {
  Write-Host "Failed to bind to all interfaces. Re-run this script as Administrator," -ForegroundColor Yellow
  Write-Host "or run once as admin: netsh http add urlacl url=http://+:$Port/ user=Everyone" -ForegroundColor Yellow
  throw
}

Write-Host "Serving $root"
Write-Host "  On this PC:      http://localhost:$Port/dashboard.html"
Write-Host "  On your phone:   http://<this-PC-LAN-IP>:$Port/dashboard.html  (find the IP via ipconfig)"
Write-Host "Shared task data lives in: $stateFile"
Write-Host "Press Ctrl+C to stop."

$mime = @{
  ".html"="text/html"; ".htm"="text/html"; ".js"="application/javascript"
  ".css"="text/css"; ".json"="application/json"; ".svg"="image/svg+xml"
  ".png"="image/png"; ".jpg"="image/jpeg"; ".ico"="image/x-icon"
}

try {
  while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    try {
      $urlPath = $request.Url.LocalPath

      if ($urlPath -eq "/api/state" -and $request.HttpMethod -eq "GET") {
        $json = if (Test-Path $stateFile) { Get-Content $stateFile -Raw -Encoding UTF8 } else { "null" }
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
        $response.ContentType = "application/json"
        $response.ContentLength64 = $bytes.Length
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
      }
      elseif ($urlPath -eq "/api/state" -and $request.HttpMethod -eq "POST") {
        $reader = New-Object System.IO.StreamReader($request.InputStream, [System.Text.Encoding]::UTF8)
        $body = $reader.ReadToEnd()
        $reader.Close()
        # Validate it's parseable JSON before writing.
        $null = $body | ConvertFrom-Json
        Set-Content -Path $stateFile -Value $body -Encoding UTF8 -NoNewline
        $ok = [System.Text.Encoding]::UTF8.GetBytes('{"ok":true}')
        $response.ContentType = "application/json"
        $response.ContentLength64 = $ok.Length
        $response.OutputStream.Write($ok, 0, $ok.Length)
      }
      else {
        $path = [System.Uri]::UnescapeDataString($urlPath.TrimStart('/'))
        if ([string]::IsNullOrWhiteSpace($path)) { $path = "dashboard.html" }
        $filePath = Join-Path $root $path

        if (Test-Path $filePath -PathType Leaf) {
          $ext = [System.IO.Path]::GetExtension($filePath)
          $contentType = $mime[$ext]
          if (-not $contentType) { $contentType = "application/octet-stream" }
          $bytes = [System.IO.File]::ReadAllBytes($filePath)
          $response.ContentType = $contentType
          $response.ContentLength64 = $bytes.Length
          $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
          $response.StatusCode = 404
          $msg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $path")
          $response.OutputStream.Write($msg, 0, $msg.Length)
        }
      }
    } catch {
      $response.StatusCode = 500
      $msg = [System.Text.Encoding]::UTF8.GetBytes("Server error: $($_.Exception.Message)")
      $response.OutputStream.Write($msg, 0, $msg.Length)
    } finally {
      $response.OutputStream.Close()
    }
  }
} finally {
  $listener.Stop()
}
