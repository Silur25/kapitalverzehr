@echo off
rem ---------------------------------------------------------------------
rem  Richtet die automatische Uebertragung auf das NAS ein.
rem  Einmal doppelklicken genuegt. Danach laeuft es von selbst.
rem ---------------------------------------------------------------------
setlocal
set "SKRIPT=%~dp0auf_nas_kopieren_still.cmd"
set "NAME=Rentenplaner auf NAS uebertragen"

echo.
echo   Automatische Uebertragung auf das NAS
echo   =====================================
echo.

if not exist "%SKRIPT%" (
  echo   FEHLER: auf_nas_kopieren_still.cmd fehlt in
  echo           %~dp0
  echo.
  pause
  exit /b 1
)

schtasks /query /tn "%NAME%" >nul 2>&1
if not errorlevel 1 (
  echo   Die Aufgabe besteht bereits und wird erneuert.
  schtasks /delete /tn "%NAME%" /f >nul 2>&1
)

schtasks /create /tn "%NAME%" /tr "\"%SKRIPT%\"" /sc minute /mo 10 /f
if errorlevel 1 (
  echo.
  echo   Die Aufgabe konnte nicht angelegt werden.
  echo   Rechte Maustaste auf diese Datei  -  "Als Administrator ausfuehren".
  echo.
  pause
  exit /b 1
)

echo.
echo   Eingerichtet. Ab jetzt wird alle zehn Minuten geprueft, ob in
echo   %~dp0
echo   eine neuere index.html liegt. Wenn ja, wandert sie auf das NAS.
echo.
echo   Protokoll:  kopier_protokoll.txt  im selben Ordner
echo.
echo   Sofort einmal ausfuehren? Dann jetzt eine Taste druecken,
echo   sonst das Fenster schliessen.
echo.
pause >nul
schtasks /run /tn "%NAME%" >nul 2>&1
echo   Ausgefuehrt. Ende.
echo.
echo   Abschalten laesst sich das jederzeit mit:
echo     schtasks /delete /tn "%NAME%" /f
echo.
pause
exit /b 0
