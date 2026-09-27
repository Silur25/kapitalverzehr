@echo off
rem ---------------------------------------------------------------------
rem  Kapitalverzehr Rieden - Einrichtung auf einem Windows-Rechner
rem
rem  Doppelklicken. Das Programm wird nach
rem      Dokumente\Kapitalverzehr
rem  gelegt, die benoetigten Ordner werden angelegt und ein Symbol auf dem
rem  Schreibtisch erstellt. Es wird nichts installiert, nichts in der
rem  Registrierung eingetragen und nichts ins Internet gesendet.
rem ---------------------------------------------------------------------
setlocal
set "QUELLE=%~dp0"
set "ZIEL=%USERPROFILE%\Documents\Kapitalverzehr"

echo.
echo   Kapitalverzehr Rieden - Einrichtung
echo   ==================================
echo.

if not exist "%QUELLE%index.html" (
  echo   FEHLER: In diesem Ordner liegt keine index.html.
  echo.
  echo   Das Paket wurde vermutlich nicht entpackt. Windows zeigt den Inhalt
  echo   einer ZIP-Datei an, ohne sie zu entpacken; von dort aus laesst sich
  echo   nichts einrichten.
  echo   Loesung: Rechtsklick auf die ZIP-Datei, "Alle extrahieren",
  echo   danach in dem entpackten Ordner diese Datei erneut starten.
  echo.
  pause
  exit /b 1
)

rem  Ordner anlegen. "daten" nimmt Sicherungen der Eingaben auf, die im
rem  Programm ueber "Exportieren" erzeugt werden.
if not exist "%ZIEL%"        mkdir "%ZIEL%"
if not exist "%ZIEL%\daten"  mkdir "%ZIEL%\daten"
if not exist "%ZIEL%\alt"    mkdir "%ZIEL%\alt"

rem  Eine bestehende Fassung zur Seite legen, statt sie zu ueberschreiben.
if exist "%ZIEL%\index.html" (
  copy /Y "%ZIEL%\index.html"  "%ZIEL%\alt\index_vorher.html" >nul 2>&1
  copy /Y "%ZIEL%\version.txt" "%ZIEL%\alt\version_vorher.txt" >nul 2>&1
  echo   Die bisherige Fassung wurde nach "alt" gesichert.
)

for %%D in (index.html version.txt start.html apple-touch-icon.png rentenplaner.ico Aktualisieren.cmd LIESMICH.txt) do (
  if exist "%QUELLE%%%D" copy /Y "%QUELLE%%%D" "%ZIEL%\%%D" >nul
)

set "FASSUNG=unbekannt"
if exist "%ZIEL%\version.txt" set /p FASSUNG=<"%ZIEL%\version.txt"
for %%A in ("%ZIEL%\index.html") do set BYTES=%%~zA

rem  Symbol auf dem Schreibtisch. Es oeffnet die Datei im Standardbrowser.
powershell -NoProfile -Command ^
  "$d=[Environment]::GetFolderPath('Desktop');" ^
  "$s=(New-Object -ComObject WScript.Shell).CreateShortcut(\"$d\Kapitalverzehr.lnk\");" ^
  "$s.TargetPath='%ZIEL%\index.html';" ^
  "$s.WorkingDirectory='%ZIEL%';" ^
  "if(Test-Path '%ZIEL%\rentenplaner.ico'){$s.IconLocation='%ZIEL%\rentenplaner.ico'};" ^
  "$s.Description='Kapitalverzehr - Budget- und Rentenberechnung';" ^
  "$s.Save()" >nul 2>&1
if errorlevel 1 (
  echo   HINWEIS: Das Symbol auf dem Schreibtisch konnte nicht erstellt werden.
  echo            Das Programm laesst sich trotzdem oeffnen - siehe unten.
) else (
  echo   Symbol "Kapitalverzehr" auf dem Schreibtisch erstellt.
)

echo.
echo   Eingerichtet: Fassung %FASSUNG%, %BYTES% Bytes
echo   Ordner:       %ZIEL%
echo.
echo   Starten:      Symbol auf dem Schreibtisch, oder im Ordner oben
echo                 die Datei index.html doppelklicken.
echo   Aktualisieren: Aktualisieren.cmd im selben Ordner.
echo.
echo   Die Eingaben werden im Browser dieses Rechners gespeichert. Sie
echo   verlassen den Rechner nicht. Eine Sicherung erstellt man im Programm
echo   mit "Exportieren"; die Datei gehoert in den Ordner "daten".
echo.

choice /C JN /N /M "  Programm jetzt oeffnen? [J/N] "
if errorlevel 2 goto :ende
start "" "%ZIEL%\index.html"

:ende
echo.
pause
exit /b 0
