@echo off
REM Installation / reparation du profil Hermes pour le PC
echo.
echo   Ouverture de l'installateur Hermes...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0installer-hermes-v2.ps1"
echo.
if exist "%~dp0installer-hermes-v2.ps1" (
  echo   L'installateur vient de s'executer. Lisez le resume a l'ecran.
) else (
  echo   ERREUR : fichier installer-hermes-v2.ps1 introuvable dans ce dossier.
)
echo.
pause
