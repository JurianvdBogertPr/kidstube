# Publiceert je lijst: pakt de nieuwste videos.json uit Downloads,
# zet hem in deze map en pusht hem naar GitHub.

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $repo

function Stop-Met($tekst, $kleur = "Red") {
    Write-Host ""
    Write-Host "  $tekst" -ForegroundColor $kleur
    Write-Host ""
    Read-Host "Druk op Enter om te sluiten"
    exit 1
}

Write-Host ""
Write-Host "  KidsTube - lijst publiceren" -ForegroundColor Cyan
Write-Host ""

# 1. Nieuwste videos.json in Downloads zoeken
$downloads = Join-Path $env:USERPROFILE "Downloads"
$kandidaten = @()
if (Test-Path $downloads) {
    $kandidaten = Get-ChildItem $downloads -Filter "videos*.json" -ErrorAction SilentlyContinue |
                  Sort-Object LastWriteTime -Descending
}

if (-not $kandidaten) {
    Stop-Met "Geen videos.json gevonden in $downloads.`n  Maak hem eerst in de app: slotje -> Instellingen -> '📤 videos.json maken'."
}

$bron = $kandidaten[0]
Write-Host "  Gevonden : $($bron.Name)  ($($bron.LastWriteTime))"

# 2. Controleren of het geldige inhoud is
try {
    $data = Get-Content $bron.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
} catch {
    Stop-Met "Dit bestand is geen geldige JSON."
}
if ($null -eq $data.videos) {
    Stop-Met "Dit bestand bevat geen videolijst."
}
Write-Host "  Inhoud   : $($data.videos.Count) video's, $($data.cats.Count) categorieen"

# 3. Naar de repo kopieren
Copy-Item $bron.FullName (Join-Path $repo "videos.json") -Force

$status = (git status --porcelain videos.json) -join ""
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host ""
    Write-Host "  De lijst is al gelijk aan wat online staat. Niets te doen." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Druk op Enter om te sluiten"
    exit 0
}

# 4. Committen en pushen
Write-Host "  Publiceren..."
git add videos.json | Out-Null
git -c user.name="KidsTube" -c user.email="kidstube@users.noreply.github.com" `
    commit -m "Lijst bijgewerkt: $($data.videos.Count) video's" | Out-Null
if ($LASTEXITCODE -ne 0) { Stop-Met "Committen mislukte." }

git push 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Stop-Met "Pushen mislukte. Controleer je internetverbinding of log opnieuw in met: gh auth login"
}

# 5. Opruimen
Remove-Item $bron.FullName -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "  Gelukt! De lijst staat online." -ForegroundColor Green
Write-Host "  Je apparaten pakken hem op binnen ~1 minuut (GitHub moet de site bijwerken)."
Write-Host "  Op de telefoon: app sluiten en opnieuw openen, of in het ouderscherm"
Write-Host "  op 'Nu ophalen' tikken."
Write-Host ""
Read-Host "Druk op Enter om te sluiten"
