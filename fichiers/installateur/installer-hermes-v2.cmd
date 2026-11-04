@echo off
REM Installation / reparation du profil Hermes pour le PC
echo.
echo   Verification de l'installateur...
if not exist "%~dp0installer-hermes-v2.ps1" (
  echo   Telechargement de l'installateur...
  powershell -NoProfile -Command "irm https://raw.githubusercontent.com/destock-rgb/podcasts/main/fichiers/installateur/installer-hermes-v2.ps1 -OutFile '%~dp0installer-hermes-v2.ps1'"
)
if not exist "%~dp0installer-hermes-v2.ps1" (
  echo.
  echo   ERREUR : l'installateur n'a pas pu etre telecharge.
  echo   Verifiez votre connexion internet et relancez.
  pause
  exit /b 1
)
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer-hermes-v2.ps1"
echo.
pause
