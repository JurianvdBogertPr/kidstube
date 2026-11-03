# KidsTube - kleine lokale webserver zodat YouTube-video's mogen afspelen.
# Start dit bestand via "KidsTube starten.cmd".

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition

$listener = $null
$port = 0
foreach ($p in 8731..8760) {
    $try = New-Object System.Net.HttpListener
    $try.Prefixes.Add("http://localhost:$p/")
    try {
        $try.Start()
        $listener = $try
        $port = $p
        break
    } catch {
        $try.Close()
    }
}

if (-not $listener) {
    Write-Host "Geen vrije poort gevonden. Sluit andere programma's en probeer opnieuw." -ForegroundColor Red
    Read-Host "Druk op Enter om te sluiten"
    exit 1
}

$url = "http://localhost:$port/index.html"
Write-Host ""
Write-Host "  KidsTube draait!" -ForegroundColor Green
Write-Host "  Adres : $url"
Write-Host "  Map   : $root"
Write-Host ""
Write-Host "  Laat dit venster openstaan zolang je kijkt."
Write-Host "  Sluit dit venster om KidsTube te stoppen."
Write-Host ""

# Open bij voorkeur in app-modus (venster zonder adresbalk en tabbladen)
$browsers = @(
    (Join-Path $env:ProgramFiles "Microsoft\Edge\Application\msedge.exe"),
    (Join-Path ${env:ProgramFiles(x86)} "Microsoft\Edge\Application\msedge.exe"),
    (Join-Path $env:ProgramFiles "Google\Chrome\Application\chrome.exe"),
    (Join-Path ${env:ProgramFiles(x86)} "Google\Chrome\Application\chrome.exe")
)
$browser = $browsers | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1

if ($browser) {
    Start-Process $browser -ArgumentList "--app=$url", "--start-maximized"
} else {
    Start-Process $url
}

$types = @{
    ".html" = "text/html; charset=utf-8"
    ".htm"  = "text/html; charset=utf-8"
    ".js"   = "text/javascript; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
}

while ($listener.IsListening) {
    try {
        $ctx = $listener.GetContext()
    } catch {
        break
    }

    $res = $ctx.Response
    try {
        $rel = [System.Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimStart('/')

        if ($rel -eq "zoek") {
            # Zoekopdracht: haalt de YouTube-resultatenpagina op (beperkte modus aan)
            $q = $ctx.Request.QueryString["q"]
            if ([string]::IsNullOrWhiteSpace($q)) {
                $res.StatusCode = 400
                $bytes = [System.Text.Encoding]::UTF8.GetBytes("Geen zoekwoord")
                $res.ContentType = "text/plain; charset=utf-8"
            } else {
                $target = "https://www.youtube.com/results?search_query=" +
                          [System.Uri]::EscapeDataString($q) + "&sp=EgIQAQ%3D%3D"
                try {
                    $yt = Invoke-WebRequest -Uri $target -UseBasicParsing -TimeoutSec 20 `
                        -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" `
                        -Headers @{ "Accept-Language" = "nl,en;q=0.8"; "Cookie" = "PREF=f2=8000000" }
                    $bytes = [System.Text.Encoding]::UTF8.GetBytes($yt.Content)
                    $res.ContentType = "text/plain; charset=utf-8"
                } catch {
                    $res.StatusCode = 502
                    $bytes = [System.Text.Encoding]::UTF8.GetBytes("Zoeken mislukt")
                    $res.ContentType = "text/plain; charset=utf-8"
                }
            }
            $res.Headers.Add("Cache-Control", "no-store")
        } else {
            if ([string]::IsNullOrWhiteSpace($rel)) { $rel = "index.html" }
            $full = Join-Path $root $rel
            $fullResolved = [System.IO.Path]::GetFullPath($full)

            $ext = [System.IO.Path]::GetExtension($fullResolved).ToLowerInvariant()

            # alleen bestanden uit de eigen map en alleen web-bestandstypen serveren
            if (-not $fullResolved.StartsWith([System.IO.Path]::GetFullPath($root), [System.StringComparison]::OrdinalIgnoreCase) -or
                -not $types.ContainsKey($ext) -or
                -not (Test-Path -LiteralPath $fullResolved -PathType Leaf)) {
                $res.StatusCode = 404
                $bytes = [System.Text.Encoding]::UTF8.GetBytes("Niet gevonden")
                $res.ContentType = "text/plain; charset=utf-8"
            } else {
                $res.ContentType = $types[$ext]
                $res.Headers.Add("Cache-Control", "no-store")
                $bytes = [System.IO.File]::ReadAllBytes($fullResolved)
            }
        }

        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } catch {
        # verbinding afgebroken: negeren
    } finally {
        try { $res.OutputStream.Close() } catch {}
    }
}

$listener.Close()
