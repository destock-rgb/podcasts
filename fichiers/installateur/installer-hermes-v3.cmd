@echo off
REM Installation du profil Hermes pour le PC - version 3
echo.
echo   Recuperation de l'installateur a jour...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://destock-rgb.github.io/podcasts/fichiers/installateur/installer-hermes-v3.ps1'; try { irm $u -OutFile '%~dp0installer-hermes-v3.ps1' -ErrorAction Stop } catch { irm 'https://raw.githubusercontent.com/destock-rgb/podcasts/main/fichiers/installateur/installer-hermes-v3.ps1' -OutFile '%~dp0installer-hermes-v3.ps1' }"
if not exist "%~dp0installer-hermes-v3.ps1" (
  echo   ERREUR : telechargement impossible. Verifiez la connexion internet.
  pause
  exit /b 1
)
echo   Installateur : %~dp0installer-hermes-v3.ps1
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer-hermes-v3.ps1"
echo.
pause
