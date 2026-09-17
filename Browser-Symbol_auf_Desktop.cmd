@echo off
rem ===========================================================================
rem  Legt die Verknuepfung zur Browser-Version auf dem Desktop ab.
rem
rem  Die Verknuepfung wird hier erzeugt, nicht kopiert. Grund: eine .url-Datei
rem  speichert den Pfad zum Symbol absolut. Eine auf einem Rechner erstellte
rem  Datei zeigt auf einem zweiten Rechner deshalb ins Leere, und Windows
rem  stellt dann eine weisse Flaeche dar. Der Pfad wird darum aus dem Ordner
rem  gebildet, in dem diese Datei gerade liegt - das stimmt auf jedem Rechner
rem  und bei jedem Benutzernamen.
rem
rem  Einmal doppelklicken genuegt.
rem ===========================================================================
setlocal
cd /d "%~dp0"
title Browser-Symbol auf den Desktop

set "ADRESSE=https://nas-speer16.tail3f0979.ts.net/rentenplaner/start.html"
set "SYMBOL=%~dp0rentenplaner.ico"
set "NAME=Kapitalverzehr im Browser.url"

echo.
echo ==========================================================
echo   Browser-Version  -  Symbol auf den Desktop legen
echo ==========================================================
echo.

if not exist "%SYMBOL%" (
  echo   HINWEIS: Die Symboldatei
  echo            %SYMBOL%
  echo   fehlt. Die Verknuepfung wird trotzdem angelegt, Windows zeigt
  echo   dann aber ein leeres Symbol.
  echo.
  set "SYMBOL="
)

rem  Verknuepfung im eigenen Ordner erzeugen
> "%~dp0%NAME%" echo [InternetShortcut]
>>"%~dp0%NAME%" echo URL=%ADRESSE%
if defined SYMBOL (
  >>"%~dp0%NAME%" echo IconFile=%SYMBOL%
  >>"%~dp0%NAME%" echo IconIndex=0
)

rem  und auf den Desktop legen
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$d=[Environment]::GetFolderPath('Desktop'); Copy-Item -LiteralPath '%~dp0%NAME%' -Destination (Join-Path $d '%NAME%') -Force; Write-Host ('Abgelegt in: ' + $d)"

if errorlevel 1 goto :fehler

rem  Windows merkt sich Symbole in einem Zwischenspeicher. Wurde das Symbol
rem  schon einmal als weisse Flaeche dargestellt, bleibt diese sonst stehen.
ie4uinit.exe -show >nul 2>&1
ie4uinit.exe -ClearIconCache >nul 2>&1

echo.
echo Fertig. Auf dem Desktop liegt jetzt das Symbol
echo   "Kapitalverzehr im Browser"
echo.
echo Es oeffnet:
echo   %ADRESSE%
echo Voraussetzung: Tailscale ist auf diesem Rechner verbunden.
echo.
echo Bleibt das Symbol weiss, einmal ab- und wieder anmelden - dann baut
echo Windows seinen Symbol-Zwischenspeicher neu auf.
echo.
pause
exit /b 0

:fehler
echo.
echo   Die Verknuepfung konnte nicht abgelegt werden.
echo   Alternative: die Datei "%NAME%"
echo   von Hand auf den Desktop ziehen.
echo.
pause
exit /b 1
