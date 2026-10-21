# Kapitalverzehr Rieden

Budget- und Rentenberechnung für zwei Personen, Schweiz — Kanton St. Gallen.

Das Programm ist **eine einzige HTML-Datei**. Es braucht keine Installation, keine
Laufzeitumgebung und keine Verbindung nach aussen. Die Eingaben werden im Browser des
jeweiligen Geräts gespeichert und verlassen den Rechner nicht.

## Installieren

1. Unter [Releases](../../releases/latest) die Datei `Kapitalverzehr_vNNN.zip` herunterladen
2. **Entpacken** — Rechtsklick, «Alle extrahieren»
3. `Installieren.cmd` doppelklicken

Angelegt werden `Dokumente\Kapitalverzehr` samt den Unterordnern `daten` und `alt`, dazu
ein Symbol auf dem Schreibtisch.

## Aktualisieren

`Aktualisieren.cmd` im Programmordner doppelklicken. Das Skript vergleicht die Fassung auf
dem Rechner mit jener hier, holt nur bei Unterschied, prüft die geladene Datei und sichert
die bisherige nach `alt`.

Im Programm selbst: Reiter **Grundlagen**, Karte **Aktualisierung**, Schaltfläche
**«Nach Updates suchen»**.

## Was das Programm rechnet

- Kapitalverzehr Jahr für Jahr, je Person, bis zum erfassten Todesjahr
- Einkommens- und Vermögenssteuer nach Steuergesetz SG und DBG, mit jährlicher Iteration
- Hypotheken mit Tranchen, Anschlusssätzen und Amortisation
- Liegenschaft, Eigenmietwert, Rückstellungskonten
- Todesfall: Erbanfall, Erbschaftssteuer, Nutzniessung, Umlage der Kosten
- Sechs Szenarien: Ausgangslage, Hypothekarsatz, erforderliches Kapital, Anlagerendite
  samt Reihenfolgerisiko, Hausverkauf zu Lebzeiten, Übertrag der Rückstellungen

## Vorbehalt

Eine Abschätzung, keine Veranlagung. Der Reiter **Grundlagen** führt unter «Offene Punkte
der Berechnung» sämtliche Annahmen, Grenzen des Modells und unsicheren Rechtsgrundlagen
auf, jeweils mit der geschätzten Wirkung auf das Ergebnis.
