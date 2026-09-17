@echo off
rem ---------------------------------------------------------------------
rem  Kopiert die Dateien aus diesem Ordner lautlos auf das NAS.
rem  Nur wenn die Quelle neuer ist als das Ziel - sonst passiert nichts.
rem  Wird von der Windows-Aufgabenplanung alle zehn Minuten aufgerufen.
rem  Fuer den Aufruf von Hand ist auf_nas_kopieren.bat gedacht.
rem
rem  Der Zielordner wird nicht mehr fest vorgegeben. Ein Laufwerksbuchstabe
rem  kann neu vergeben werden - dann zeigt er auf eine andere Freigabe, und
rem  das Kopieren schlaegt stillschweigend fehl. Deshalb werden mehrere Orte
rem  der Reihe nach geprueft und der erste vorhandene genommen. Eine eigene
rem  Vorgabe geht vor: eine Zeile mit dem Pfad in der Datei nas_ziel.txt.
rem ---------------------------------------------------------------------
setlocal
set "ORDNER=%~dp0"
set "LOG=%~dp0kopier_protokoll.txt"

set "ZIEL="
if exist "%ORDNER%nas_ziel.txt" (
  for /f "usebackq delims=" %%Z in ("%ORDNER%nas_ziel.txt") do (
    if not defined ZIEL if exist "%%~Z\" set "ZIEL=%%~Z"
  )
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
  echo %DATE% %TIME%  kein Zielordner gefunden - geprueft: Q:\kapitalverzehr, \\NAS-Speer16\web\kapitalverzehr, \\nas-speer16.tail3f0979.ts.net\web\kapitalverzehr, \\100.109.66.45\web\kapitalverzehr>>"%LOG%"
  exit /b 0
)

rem  version.txt aus der index.html nachfuehren. Massgebend ist die Nummer im
rem  Kopf der Seite (id="chipVersion">vNNN<). Geschrieben wird nur, wenn sich
rem  der Inhalt aendert - sonst wuerde die Datei bei jedem Lauf neu datiert
rem  und von xcopy /D unnoetig erneut uebertragen.
set "QF="
if not exist "%ORDNER%index.html" goto :ohne_quelle
for /f "usebackq delims=" %%V in (`powershell -NoProfile -Command "$t=[IO.File]::ReadAllText('%ORDNER%index.html');$m=[regex]::Match($t,'id=.chipVersion.>\s*(v[0-9]+)');if($m.Success){$m.Groups[1].Value}"`) do set "QF=%%V"
:ohne_quelle
set "ALTF="
if exist "%ORDNER%version.txt" set /p ALTF=<"%ORDNER%version.txt"
if defined QF if /i not "%ALTF%"=="%QF%" (
  > "%ORDNER%version.txt" echo %QF%
  echo %DATE% %TIME%  version.txt von %ALTF% auf %QF% nachgefuehrt>>"%LOG%"
)

for %%D in (index.html start.html version.txt speichern.php apple-touch-icon.png) do (
  if exist "%ORDNER%%%D" xcopy /D /Y /Q "%ORDNER%%%D" "%ZIEL%\" >nul 2>&1
)

set "QG="
set "ZG="
for %%A in ("%ORDNER%index.html") do set QG=%%~zA
for %%A in ("%ZIEL%\index.html")  do set ZG=%%~zA
if "%QG%"=="%ZG%" (
  echo %DATE% %TIME%  aktuell, %ZG% Bytes  [%ZIEL%]>>"%LOG%"
) else (
  echo %DATE% %TIME%  kopiert, Quelle %QG% Bytes, Ziel %ZG% Bytes  [%ZIEL%]>>"%LOG%"
)

exit /b 0
