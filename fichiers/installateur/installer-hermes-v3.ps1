# -*- coding: utf-8 -*-
# Hermes Desktop - installation complete du profil (Windows)
# Cible officielle : %LOCALAPPDATA%\hermes (HERMES_HOME par defaut sous Windows)

$ErrorActionPreference = "Continue"
$Y = "Yellow"; $G = "Green"; $R = "Red"; $C = "Cyan"; $N = "Gray"; $B = "White"; $V = "Green"
function Dire($m, $c) { Write-Host $m -ForegroundColor $c }
function Titre($m) { Write-Host ""; Write-Host "=== $m ===" -ForegroundColor $B }

# Les 3 emplacements possibles du profil Hermes sous Windows
$racineDefaut = Join-Path $env:LOCALAPPDATA "hermes"           # HERMES_HOME officiel sous Windows
$racineUnix   = Join-Path $env:USERPROFILE ".hermes"            # variante POSIX
$profilsDefaut = Join-Path $racineDefaut "profiles"

Titre "1/7 - Emplacements"
Dire "  HERMES_HOME officiel : $racineDefaut" $N
Dire "  variante POSIX        : $racineUnix" $N
Dire "  dossier utilisateur   : $env:USERPROFILE" $N

Titre "2/7 - Recherche du paquet"
$ouChercher = @($PSScriptRoot, (Join-Path $env:USERPROFILE "Downloads"), (Join-Path $env:USERPROFILE "Desktop"),
                (Join-Path $env:USERPROFILE "Bureau"), (Join-Path $env:USERPROFILE "Documents")) |
              Where-Object { $_ -and (Test-Path $_) }
$paquet = $null
foreach ($d in $ouChercher) {
    $t = @(Get-ChildItem -Path $d -Filter "profil-hermes-pour-desktop*.tar.gz" -File -ErrorAction SilentlyContinue)
    if ($t.Count -gt 0) { $paquet = ($t | Sort-Object LastWriteTime -Descending)[0]; break }
}
if (-not $paquet) {
    Dire "  ECHEC : profil-hermes-pour-desktop.tar.gz introuvable." $R
    Dire "  Cherche dans : $($ouChercher -join ', ')" $N
    Write-Host ""; Read-Host "  Entree pour fermer"; exit 1
}
Dire "  trouve : $($paquet.FullName)  ($([math]::Round($paquet.Length/1KB)) Ko)" $V

Titre "3/7 - Extraction"
$tmp = Join-Path $env:TEMP "hermes-profil-instal3"
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
& tar.exe -xzf $paquet.FullName -C $tmp
if ($LASTEXITCODE -ne 0) { Dire "  ECHEC : extraction impossible." $R; exit 1 }
$src = Get-ChildItem -Path $tmp -Directory -Recurse -ErrorAction SilentlyContinue |
       Where-Object { Test-Path (Join-Path $_.FullName "config.yaml") } | Select-Object -First 1
if (-not $src) { Dire "  ECHEC : config.yaml introuvable dans le paquet." $R; exit 1 }
Dire "  source : $($src.FullName)" $V

Titre "4/7 - Copie vers tous les emplacements possibles"
$cibles = @(
    (Join-Path $profilsDefaut "med"),
    $racineDefaut,
    (Join-Path $racineUnix "profiles\med"),
    $racineUnix
)
foreach ($dest in $cibles) {
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Get-ChildItem $src.FullName -Force | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $dest -Recurse -Force -ErrorAction SilentlyContinue
    }
    Dire "  copie -> $dest" $V
}

Titre "5/7 - Correction des chemins (Linux -> Windows)"
$hermesMem = $null
$found = @(Get-ChildItem -Path (Join-Path $env:APPDATA "Python"), (Join-Path $env:LOCALAPPDATA "Programs\Python") `
    -Filter "hermes-memory.exe" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1)
if ($found.Count -gt 0) { $hermesMem = $found[0].FullName }
if ($hermesMem) { Dire "  hermes-memory : $hermesMem" $V }
else { Dire "  hermes-memory absent : la memoire native fonctionnera, le MCP sera ignore." $Y }

foreach ($dest in $cibles) {
    $cfg = Join-Path $dest "config.yaml"
    if (-not (Test-Path $cfg)) { continue }
    $txt = [System.IO.File]::ReadAllText($cfg)
    $db = (Join-Path $dest "memory.db").Replace('\','/')
    $txt = $txt.Replace("/data/profiles/med/memory.db", $db)
    if ($hermesMem) { $txt = $txt.Replace("/data/.local/bin/hermes-memory", $hermesMem.Replace('\','/')) }
    [System.IO.File]::WriteAllText($cfg, $txt, (New-Object System.Text.UTF8Encoding($false)))
    Dire "  chemins corriges : $cfg" $V
}

Titre "6/7 - Installation de la memoire et de la voix (si possible)"
$py = $null
foreach ($c in @("py", "python", "python3")) {
    $v = (Get-Command $c -ErrorAction SilentlyContinue)
    if ($v) { $py = $c; break }
}
if ($py) {
    Dire "  python trouve : $py" $V
    & $py -m pip install --quiet --disable-pip-version-check hermes-memory edge-tts 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { Dire "  OK  hermes-memory et edge-tts installes" $G }
    else { Dire "  ATTENTION : installation pip incomplete (pas bloquant)" $Y }
} else { Dire "  ATTENTION : python introuvable (pas bloquant)" $Y }

Titre "7/7 - Verification"
foreach ($dest in $cibles) {
    $cfg = Join-Path $dest "config.yaml"
    $envf = Join-Path $dest ".env"
    $etat = @()
    if (Test-Path $cfg) { $etat += "config" } else { $etat += "SANS config" }
    if (Test-Path $envf) { $etat += "env" } else { $etat += "SANS env" }
    if (Test-Path (Join-Path $dest "memory.db")) { $etat += "memoire" } else { $etat += "SANS memoire" }
    $nb = @(Get-ChildItem (Join-Path $dest "skills") -Recurse -Filter "SKILL.md" -ErrorAction SilentlyContinue).Count
    if ($nb -gt 0) { $etat += "$nb competences" }
    $couleur = if ($etat -contains "SANS config") { $R } else { $G }
    Dire ("  " + ($etat -join ", ")) $couleur
    Dire "     $dest" $N
}

Write-Host ""
Dire "  PROCHAINE ETAPE :" $B
Dire "    1. Fermez Hermes Desktop (icone X en haut a droite)" $C
Dire "    2. Rouvrez Hermes Desktop" $C
Dire "    3. Nouvelle session, ecrivez : bonjour" $C
Write-Host ""
Write-Host "  Vous pouvez fermer cette fenetre."
