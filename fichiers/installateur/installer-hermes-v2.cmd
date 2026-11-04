@echo off
REM Installation / reparation du profil Hermes pour le PC
echo.
echo   Recuperation de l'installateur a jour...
powershell -NoProfile -Command "irm https://raw.githubusercontent.com/destock-rgb/podcasts/main/fichiers/installateur/installer-hermes-v2.ps1 -OutFile '%~dp0installer-hermes-v2.ps1'"
if not exist "%~dp0installer-hermes-v2.ps1" (
  echo   ERREUR : telechargement impossible. Verifiez la connexion internet.
  pause
  exit /b 1
)
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer-hermes-v2.ps1"
echo.
pause
