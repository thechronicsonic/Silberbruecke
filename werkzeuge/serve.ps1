# Lokaler Server für die Entwicklung.
#
# Über file:// laufen manche Browser in Einschränkungen; außerdem cachen sie
# hartnäckig. Dieser Server liefert alles mit Cache-Control: no-store aus, ein
# F5 zeigt also wirklich den neuen Stand.
#
#   powershell -ExecutionPolicy Bypass -File werkzeuge\serve.ps1
#   dann http://localhost:8731/ im Browser
#
# Beenden mit Strg+C.

$root = Split-Path -Parent $PSScriptRoot          # der Projektordner
$l = New-Object System.Net.HttpListener
$l.Prefixes.Add('http://localhost:8731/')
$l.Start()
Write-Host "Silberbrücke laeuft auf http://localhost:8731/  (Wurzel: $root)"
while ($l.IsListening) {
  $ctx = $l.GetContext()
  $rel = $ctx.Request.Url.LocalPath.TrimStart('/')
  if ($rel -eq '') { $rel = 'silberbruecke.html' }
  $f = Join-Path $root $rel
  # Nicht aus dem Projektordner herausreichen lassen.
  $voll = [IO.Path]::GetFullPath($f)
  if ($voll.StartsWith([IO.Path]::GetFullPath($root)) -and (Test-Path $voll -PathType Leaf)) {
    $b = [System.IO.File]::ReadAllBytes($voll)
    $ctx.Response.ContentType = 'text/html; charset=utf-8'
    $ctx.Response.Headers.Add('Cache-Control','no-store')
    $ctx.Response.OutputStream.Write($b, 0, $b.Length)
  } else { $ctx.Response.StatusCode = 404 }
  $ctx.Response.Close()
}
