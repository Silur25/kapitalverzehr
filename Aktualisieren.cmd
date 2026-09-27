@echo off
rem ---------------------------------------------------------------------
rem  Kapitalverzehr Rieden - Aktualisierung ueber GitHub
rem
rem  Holt die neueste Fassung aus dem oeffentlichen Verzeichnis
rem      https://github.com/Silur25/kapitalverzehr
rem  und ersetzt die Datei im Programmordner. Die Eingaben bleiben davon
rem  unberuehrt: sie liegen im Browser, nicht in der Datei.
rem
rem  Geprueft wird vor dem Ersetzen:
rem    - die heruntergeladene Datei ist mindestens 200 000 Bytes gross
rem    - sie traegt im Kopf die Kennung  id="chipVersion">vNNN<
rem  Erst dann wird die bisherige Fassung nach "alt" gesichert und ersetzt.
rem ---------------------------------------------------------------------
setlocal
set "ORDNER=%~dp0"
set "ROH=https://raw.githubusercontent.com/Silur25/kapitalverzehr/main"
rem  raw.githubusercontent.com liefert aus einem Zwischenspeicher, der eine
rem  neue Datei einige Minuten lang verschweigt. Eine jedes Mal andere
rem  Kennung in der Adresse umgeht ihn.
set "KENN=?t=%RANDOM%%RANDOM%"

echo.
echo   Kapitalverzehr Rieden - Aktualisierung
echo   =====================================
echo.

set "HIER=unbekannt"
if exist "%ORDNER%version.txt" set /p HIER=<"%ORDNER%version.txt"
echo   Auf diesem Rechner: Fassung %HIER%

rem  Fassungsnummer im Verzeichnis abfragen.
set "DORT="
for /f "usebackq delims=" %%V in (`powershell -NoProfile -Command "try{(Invoke-WebRequest -UseBasicParsing -Uri '%ROH%/version.txt%KENN%' -TimeoutSec 25).Content.Trim()}catch{''}"`) do set "DORT=%%V"

if not defined DORT (
  echo   Das Verzeichnis ist nicht erreichbar.
  echo   Moegliche Gruende: keine Internetverbindung, oder das Verzeichnis
  echo   ist nicht oeffentlich.
  echo.
  pause
  exit /b 1
)
echo   Im Verzeichnis:     Fassung %DORT%
echo.

if /i "%HIER%"=="%DORT%" (
  echo   Es liegt bereits die neueste Fassung vor. Nichts zu tun.
  echo.
  pause
  exit /b 0
)

echo   Neue Fassung wird geholt ...
set "TMP=%TEMP%\kapitalverzehr_neu.html"
if exist "%TMP%" del "%TMP%" >nul 2>&1
powershell -NoProfile -Command "try{Invoke-WebRequest -UseBasicParsing -Uri '%ROH%/index.html%KENN%' -OutFile '%TMP%' -TimeoutSec 180}catch{exit 1}"
if errorlevel 1 goto :fehlgeschlagen
if not exist "%TMP%" goto :fehlgeschlagen

rem  Pruefung der heruntergeladenen Datei.
set "GEPRUEFT="
for /f "usebackq delims=" %%P in (`powershell -NoProfile -Command "$f=Get-Item '%TMP%' -EA 0; if(-not $f){'nein';exit}; if($f.Length -lt 200000){'nein';exit}; $t=[IO.File]::ReadAllText($f.FullName); $m=[regex]::Match($t,'id=.chipVersion.>\s*(v[0-9]+)'); if($m.Success){$m.Groups[1].Value}else{'nein'}"`) do set "GEPRUEFT=%%P"

if "%GEPRUEFT%"=="nein" (
  echo   FEHLER: Die heruntergeladene Datei ist nicht das Programm.
  echo           Sie wird nicht uebernommen; die bisherige Fassung bleibt.
  del "%TMP%" >nul 2>&1
  echo.
  pause
  exit /b 1
)
if not defined GEPRUEFT goto :fehlgeschlagen

for %%A in ("%TMP%") do set NBYTES=%%~zA
echo   Geprueft: Fassung %GEPRUEFT%, %NBYTES% Bytes, Kennung des Rentenplaners vorhanden.

if not exist "%ORDNER%alt" mkdir "%ORDNER%alt"
if exist "%ORDNER%index.html"  copy /Y "%ORDNER%index.html"  "%ORDNER%alt\index_%HIER%.html" >nul 2>&1
if exist "%ORDNER%version.txt" copy /Y "%ORDNER%version.txt" "%ORDNER%alt\version_%HIER%.txt" >nul 2>&1

move /Y "%TMP%" "%ORDNER%index.html" >nul
if errorlevel 1 (
  echo   FEHLER beim Ersetzen. Ist das Programm im Browser geoeffnet?
  echo   Bitte schliessen und noch einmal versuchen.
  echo.
  pause
  exit /b 1
)
> "%ORDNER%version.txt" echo %GEPRUEFT%

rem  Begleitdateien mitnehmen, sofern vorhanden. Fehlen sie im Verzeichnis,
rem  bleibt die bisherige Datei stehen - deshalb in eine Kopie laden.
for %%D in (start.html apple-touch-icon.png rentenplaner.ico Installieren.cmd Aktualisieren.cmd LIESMICH.txt) do (
  powershell -NoProfile -Command "try{Invoke-WebRequest -UseBasicParsing -Uri '%ROH%/%%D%KENN%' -OutFile '%TEMP%\kv_%%D' -TimeoutSec 60; if((Get-Item '%TEMP%\kv_%%D').Length -gt 0){Move-Item -Force '%TEMP%\kv_%%D' '%ORDNER%%%D'}}catch{}" >nul 2>&1
)

echo.
echo   Fertig. Neu eingerichtet: Fassung %GEPRUEFT%
echo   Die bisherige Fassung %HIER% liegt im Ordner "alt".
echo.
echo   WICHTIG: Im Browser einmal mit Strg + F5 neu laden, sonst zeigt er
echo            die alte Fassung aus seinem Zwischenspeicher.
echo.
pause
exit /b 0

:fehlgeschlagen
echo   FEHLER: Die Datei konnte nicht geladen werden.
echo   Die bisherige Fassung bleibt unveraendert.
echo.
pause
exit /b 1
