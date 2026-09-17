@echo off
rem ---------------------------------------------------------------------
rem  Kopiert die aktuelle index.html aus diesem Ordner auf das NAS.
rem  Einfach doppelklicken. Claude legt die neue Fassung neben diese Datei.
rem
rem  Der Zielordner wird selbst gesucht: ein Laufwerksbuchstabe kann neu
rem  vergeben werden und zeigt dann auf eine andere Freigabe. Geprueft wird
rem  der Reihe nach, was in nas_ziel.txt steht, dann die bekannten Orte.
rem ---------------------------------------------------------------------
setlocal
set "ORDNER=%~dp0"
set "QUELLE=%ORDNER%index.html"

echo.
echo   Kapitalverzehr auf das NAS kopieren
echo   ===================================
echo.

rem  Warnung vor doppelten Dateien. Windows ueberschreibt eine vorhandene Datei
rem  nicht immer, sondern legt sie als "... (1)" oder "...-1" daneben. Dann
rem  startet man weiter die alte Fassung, ohne es zu merken.
set "DOPPELT="
for %%F in ("%ORDNER%index (*.html" "%ORDNER%index-*.html"
            "%ORDNER%auf_nas_kopieren-*.bat" "%ORDNER%auf_nas_kopieren_still-*.cmd"
            "%ORDNER%version (*.txt" "%ORDNER%version-*.txt") do (
  if exist "%%~F" set "DOPPELT=1"
)
if defined DOPPELT (
  echo   ACHTUNG: In diesem Ordner liegen doppelte Dateien:
  echo.
  dir /b "%ORDNER%index (*.html" "%ORDNER%index-*.html" "%ORDNER%auf_nas_kopieren-*.bat" "%ORDNER%auf_nas_kopieren_still-*.cmd" "%ORDNER%version (*.txt" "%ORDNER%version-*.txt" 2^>nul
  echo.
  echo   Windows hat beim Herunterladen nicht ueberschrieben, sondern danebengelegt.
  echo   Die alte Datei bleibt dadurch in Gebrauch. Bitte aufraeumen:
  echo   die alte loeschen, die neue auf den richtigen Namen umbenennen.
  echo.
)

rem ---------------------------------------------------------------------
rem  Neue Fassung selbst aus dem Ablageordner der Claude-App holen.
rem
rem  Die App legt heruntergeladene Dateien fest in "Claude outputs" ab; der
rem  Ordner laesst sich in der App nicht umstellen. Windows benennt eine
rem  zweite Datei zudem in index-1.html um, statt zu ueberschreiben. Beides
rem  wird hier aufgeloest: die neueste index*.html aus den bekannten
rem  Ablageordnern wird hereingeholt, sofern sie neuer ist als die Datei in
rem  diesem Ordner. Damit entfaellt das Verschieben von Hand.
rem ---------------------------------------------------------------------
set "HOLQ="
for /f "usebackq delims=" %%F in (`powershell -NoProfile -Command "$o=@('%USERPROFILE%\Documents\Hilti Messsensoren_Daten\Claude outputs','%USERPROFILE%\Downloads'); $a=Get-Item '%QUELLE%' -EA 0; $n=$null; foreach($p in $o){ if(Test-Path $p){ foreach($f in Get-ChildItem -LiteralPath $p -Filter 'index*.html' -File -EA 0){ if(-not $n -or $f.LastWriteTime -gt $n.LastWriteTime){$n=$f} } } }; if($n -and (-not $a -or $n.LastWriteTime -gt $a.LastWriteTime)){$n.FullName}"`) do set "HOLQ=%%F"

if not defined HOLQ goto :nichts_zu_holen
echo   Neuere Fassung im Ablageordner gefunden:
echo   %HOLQ%
move /Y "%HOLQ%" "%QUELLE%" >nul
if errorlevel 1 (
  echo   HINWEIS: Die Datei konnte nicht hereingeholt werden.
  echo            Moeglicherweise ist sie im Browser oder Editor offen.
) else (
  echo   In diesen Ordner uebernommen als index.html.
)
echo.
:nichts_zu_holen

if not exist "%QUELLE%" (
  echo   FEHLER: Im Ordner
  echo           %ORDNER%
  echo   liegt keine index.html. Claude legt sie dort ab -
  echo   bitte zuerst die neue Fassung anfordern.
  echo.
  pause
  exit /b 1
)

rem  Fassung der Quelle bestimmen, bevor kopiert wird.
rem
rem  Massgebend ist die index.html selbst: sie traegt ihre Nummer im Kopf der
rem  Seite als  id="chipVersion">vNNN<  . version.txt wird daraus neu
rem  geschrieben. Damit kann die Begleitdatei nicht mehr veralten, wenn beim
rem  Herunterladen nur die index.html erneuert wurde.
set "QFASSUNG="
for /f "usebackq delims=" %%V in (`powershell -NoProfile -Command "$t=[IO.File]::ReadAllText('%QUELLE%');$m=[regex]::Match($t,'id=.chipVersion.>\s*(v[0-9]+)');if($m.Success){$m.Groups[1].Value}"`) do set "QFASSUNG=%%V"
for %%A in ("%QUELLE%") do set QBYTES=%%~zA

if not defined QFASSUNG goto :ohne_nummer

set "ALT=fehlt"
if exist "%ORDNER%version.txt" set /p ALT=<"%ORDNER%version.txt"
> "%ORDNER%version.txt" echo %QFASSUNG%
echo   Im Ordner liegt: Fassung %QFASSUNG%, %QBYTES% Bytes
echo   %ORDNER%
if /i not "%ALT%"=="%QFASSUNG%" echo   version.txt stand auf %ALT% - auf %QFASSUNG% nachgefuehrt.
goto :fassung_fertig

:ohne_nummer
set "QFASSUNG=unbekannt"
if exist "%ORDNER%version.txt" set /p QFASSUNG=<"%ORDNER%version.txt"
echo   Im Ordner liegt: Fassung %QFASSUNG%, %QBYTES% Bytes
echo   %ORDNER%
echo   HINWEIS: In der index.html wurde keine Fassungsnummer gefunden.
echo            Es gilt der Eintrag aus version.txt, er kann veraltet sein.

:fassung_fertig
echo.

set "ZIEL="
if exist "%ORDNER%nas_ziel.txt" (
  for /f "usebackq delims=" %%Z in ("%ORDNER%nas_ziel.txt") do (
    if not defined ZIEL if exist "%%~Z\" set "ZIEL=%%~Z"
  )
  if defined ZIEL echo   Ziel aus nas_ziel.txt uebernommen.
)
if not defined ZIEL (
  for %%K in (
    "Q:\kapitalverzehr"
    "\\NAS-Speer16\web\kapitalverzehr"
    "\\nas-speer16.tail3f0979.ts.net\web\kapitalverzehr"
    "\\100.109.66.45\web\kapitalverzehr"
  ) do (
    if not defined ZIEL if exist "%%~K\" set "ZIEL=%%~K"
  )
)

if not defined ZIEL (
  echo   FEHLER: Der Zielordner wurde an keinem der bekannten Orte gefunden.
  echo.
  echo   Geprueft wurden:
  echo     Q:\kapitalverzehr
  echo     \\NAS-Speer16\web\kapitalverzehr
  echo     \\nas-speer16.tail3f0979.ts.net\web\kapitalverzehr
  echo     \\100.109.66.45\web\kapitalverzehr
  echo.
  echo   Was jetzt auf den Laufwerken liegt:
  echo.
  net use
  echo.
  echo   Inhalt der Freigabe web auf NAS-Speer16, sofern erreichbar:
  dir "\\NAS-Speer16\web" /b 2>nul
  if errorlevel 1 echo     - nicht erreichbar -
  echo.
  echo   Loesung: den richtigen Pfad in eine Datei nas_ziel.txt
  echo   in diesem Ordner schreiben, eine Zeile, ohne Anfuehrungszeichen.
  echo.
  pause
  exit /b 1
)

echo   Ziel: %ZIEL%
echo.

copy /Y "%QUELLE%" "%ZIEL%\index.html" >nul
if errorlevel 1 (
  echo   FEHLER beim Kopieren. Moeglicherweise fehlt das Schreibrecht
  echo   auf der Freigabe, oder die Datei ist auf dem NAS gerade offen.
  echo.
  pause
  exit /b 1
)

for %%D in (version.txt start.html speichern.php apple-touch-icon.png) do (
  if exist "%ORDNER%%%D" (
    copy /Y "%ORDNER%%%D" "%ZIEL%\%%D" >nul
    if errorlevel 1 (
      echo   HINWEIS: %%D konnte nicht kopiert werden.
    ) else (
      echo   %%D ebenfalls kopiert.
    )
  )
)

set "GROESSE="
for %%A in ("%ZIEL%\index.html") do set GROESSE=%%~zA
set "FASSUNG=unbekannt"
if exist "%ZIEL%\version.txt" set /p FASSUNG=<"%ZIEL%\version.txt"

echo.
echo   Fertig. %GROESSE% Bytes kopiert nach
echo   %ZIEL%\index.html
echo   Fassung auf dem NAS: %FASSUNG%
echo.
echo   Das Desktop-Symbol oeffnet start.html - diese Seite holt das
echo   Programm immer frisch vom NAS. Ein Strg + F5 ist nicht mehr noetig.
echo.
pause
exit /b 0
