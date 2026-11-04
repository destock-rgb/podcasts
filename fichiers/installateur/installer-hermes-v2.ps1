# -*- coding: utf-8 -*-
# Hermes Desktop - installation / reparation du profil
# Copie le profil dans TOUS les dossiers de profil trouves, corrige les chemins
# et verifie que le modele et la cle API sont bien en place.

$ErrorActionPreference = "Continue"
$Y = "Yellow"; $G = "Green"; $R = "Red"; $C = "Cyan"; $N = "Gray"; $B = "White"; $V = "Green"

function Dire($m, $c) { Write-Host $m -ForegroundColor $c }
function Titre($m) { Write-Host ""; Write-Host "=== $m ===" -ForegroundColor $B }

$hermesDir  = Join-Path $env:USERPROFILE ".hermes"
$profilsDir = Join-Path $hermesDir "profiles"

Titre "1/6 - Ouverture de la fenetre"
Dire "  Dossier utilisateur : $env:USERPROFILE" $N
Dire "  Dossier Hermes     : $hermesDir" $N

# ---------------------------------------------------------------- paquet
Titre "2/6 - Recherche du paquet profil-hermes-pour-desktop.tar.gz"
$ouChercher = @(
    $PSScriptRoot,
    (Join-Path $env:USERPROFILE "Downloads"),
    (Join-Path $env:USERPROFILE "Desktop"),
    (Join-Path $env:USERPROFILE "Bureau"),
    (Join-Path $env:USERPROFILE "Documents")
) | Where-Object { $_ -and (Test-Path $_) }

$paquet = $null
foreach ($d in $ouChercher) {
    $t = @(Get-ChildItem -Path $d -Filter "profil-hermes-pour-desktop*.tar.gz" -File -ErrorAction SilentlyContinue)
    if ($t.Count -gt 0) {
        $t = $t | Sort-Object LastWriteTime -Descending
        $paquet = $t[0]
        Dire "  trouve : $($paquet.FullName)" $V
        break
    }
}
if (-not $paquet) {
    Dire "  ECHEC : le paquet .tar.gz est introuvable." $R
    Dire "  Cherche dans : $($ouChercher -join ', ')" $N
    Dire "  => Telechargez le fichier profil-hermes-pour-desktop.tar.gz dans ce dossier," $Y
    Dire "     puis relancez ce fichier." $Y
    exit 1
}
Dire "  taille : $([math]::Round($paquet.Length/1KB)) Ko" $N

# ---------------------------------------------------------------- extraction
Titre "3/6 - Extraction"
$tmp = Join-Path $env:TEMP "hermes-profil-instal2"
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
& tar.exe -xzf $paquet.FullName -C $tmp
if ($LASTEXITCODE -ne 0) { Dire "  ECHEC : extraction impossible." $R; exit 1 }
$src = Get-ChildItem -Path $tmp -Directory -Recurse -ErrorAction SilentlyContinue |
       Where-Object { Test-Path (Join-Path $_.FullName "config.yaml") } | Select-Object -First 1
if (-not $src) { Dire "  ECHEC : config.yaml introuvable dans le paquet." $R; exit 1 }
Dire "  source : $($src.FullName)" $V

# ---------------------------------------------------------------- profils
Titre "4/6 - Dossiers de profil"
if (-not (Test-Path $profilsDir)) { New-Item -ItemType Directory -Force -Path $profilsDir | Out-Null }
$cibles = @()
$existants = @(Get-ChildItem $profilsDir -Directory -ErrorAction SilentlyContinue)
foreach ($p in $existants) {
    $cibles += $p.FullName
    $etat = if (Test-Path (Join-Path $p.FullName "config.yaml")) { "config deja present" } else { "profil vide" }
    Dire "  profil existant : $($p.Name)  ($etat)" $N
}
if ($cibles.Count -eq 0) {
    $cibles += (Join-Path $profilsDir "med")
    Dire "  aucun profil : creation de 'med'" $Y
}
# le dossier racine .hermes peut aussi servir de profil
if (Test-Path (Join-Path $hermesDir "config.yaml")) { $cibles += $hermesDir }

foreach ($dest in $cibles) {
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Get-ChildItem $src.FullName -Force | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $dest -Recurse -Force -ErrorAction SilentlyContinue
    }
    # le .env aussi a la racine .hermes (certains builds le lisent la)
    if (Test-Path (Join-Path $dest ".env")) {
        Copy-Item -Path (Join-Path $dest ".env") -Destination (Join-Path $hermesDir ".env") -Force -ErrorAction SilentlyContinue
    }
    Dire "  -> copie faite dans : $dest" $V
}

# ---------------------------------------------------------------- chemins
Titre "5/6 - Correction des chemins (Linux -> Windows)"
$hermesMemExe = $null
foreach ($cand in @(
    (Join-Path $env:APPDATA "Python\Scripts\hermes-memory.exe"),
    (Join-Path $env:LOCALAPPDATA "Programs\Python\Scripts\hermes-memory.exe"),
    (Join-Path $env:APPDATA "Python\Python312\Scripts\hermes-memory.exe"),
    (Join-Path $env:APPDATA "Python\Python313\Scripts\hermes-memory.exe")
)) { if (Test-Path $cand) { $hermesMemExe = $cand; break } }
if (-not $hermesMemExe) {
    $found = @(Get-ChildItem -Path $env:APPDATA,$env:LOCALAPPDATA -Filter "hermes-memory.exe" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1)
    if ($found.Count -gt 0) { $hermesMemExe = $found[0].FullName }
}
if ($hermesMemExe) { Dire "  hermes-memory trouve : $hermesMemExe" $V }
else { Dire "  hermes-memory introuvable : la memoire sera rechargee plus tard (pas bloquant)." $Y }

foreach ($dest in $cibles) {
    $cfg = Join-Path $dest "config.yaml"
    if (-not (Test-Path $cfg)) { continue }
    $txt = [System.IO.File]::ReadAllText($cfg)
    $dbWin = (Join-Path $dest "memory.db").Replace('\','/')
    $txt = $txt.Replace("/data/profiles/med/memory.db", $dbWin)
    if ($hermesMemExe) { $txt = $txt.Replace("/data/.local/bin/hermes-memory", $hermesMemExe.Replace('\','/')) }
    [System.IO.File]::WriteAllText($cfg, $txt, (New-Object System.Text.UTF8Encoding($false)))
    Dire "  chemins corriges dans : $cfg" $V
}

# ---------------------------------------------------------------- verification
Titre "6/6 - Verification"
$dest = $cibles[0]
$cfg = Join-Path $dest "config.yaml"
$txt = if (Test-Path $cfg) { [System.IO.File]::ReadAllText($cfg) } else { "" }
if ($txt -match "model:") { Dire "  OK  config.yaml present, bloc model: trouve" $G } else { Dire "  ECHEC : pas de bloc model:" $R }
if ($txt -match "provider:\s*ollama") { Dire "  OK  fournisseur : ollama (ollama.com)" $G } else { Dire "  ATTENTION : fournisseur non trouve dans la config" $Y }
if ($txt -match "default:\s*minimax") { Dire "  OK  modele : minimax-m3.1-flash" $G }
if (Test-Path (Join-Path $dest ".env")) {
    $envTxt = [System.IO.File]::ReadAllText((Join-Path $dest ".env"))
    if ($envTxt -match "OLLAMA_API_KEY=\s*\S+") { Dire "  OK  cle OLLAMA_API_KEY presente (valeur masquee)" $G }
    else { Dire "  ECHEC : OLLAMA_API_KEY absent ou vide" $R }
} else { Dire "  ECHEC : .env absent" $R }
if (Test-Path (Join-Path $dest "memory.db")) { Dire "  OK  memory.db present" $G } else { Dire "  ATTENTION : memory.db absent" $Y }
$nb = @(Get-ChildItem (Join-Path $dest "skills") -Recurse -Filter "SKILL.md" -ErrorAction SilentlyContinue).Count
if ($nb -gt 0) { Dire "  OK  $nb competences installees" $G }

Write-Host ""
Dire "  TOUT EST INSTALLE dans : $dest" $G
Write-Host ""
Dire "  Prochaine etape :" $B
Dire "    1. Fermez Hermes Desktop s'il est ouvert, puis rouvrez-le" $C
Dire "    2. Dans la barre laterale, choisissez le profil '$([System.IO.Path]::GetFileName($dest))'" $C
Dire "    3. Ouvrez une NOUVELLE session et ecrivez : bonjour" $C
Write-Host ""
Dire "  Si le message 'No inference provider configured' revient," $N
Dire "  faites une capture d'ecran de la fenetre et envoyez-la." $N
Write-Host ""
Write-Host "  Vous pouvez fermer cette fenetre."
